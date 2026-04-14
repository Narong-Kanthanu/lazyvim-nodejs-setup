#!/usr/bin/env python3
"""
vault-graph.py — Obsidian vault graph generator
Scans [[wikilinks]] and generates an interactive D3 force-directed graph.

Usage:
    python3 vault-graph.py ~/notes
    python3 vault-graph.py ~/notes --output ~/notes/graph.html
    python3 vault-graph.py ~/notes --no-open

    # Workspace selection (reads PERSONAL_VAULT_PATH / WORK_VAULT_PATH env vars)
    python3 vault-graph.py                # interactive picker
    python3 vault-graph.py -w personal    # select workspace by name
    python3 vault-graph.py -w work
    python3 vault-graph.py --all          # all workspaces with in-browser selector
    python3 vault-graph.py --list         # list available workspaces
"""

import os
import re
import json
import argparse
import webbrowser
from pathlib import Path
from collections import defaultdict


# ── Workspaces ───────────────────────────────────────────────────────────────

WORKSPACES = {
    "personal": "PERSONAL_VAULT_PATH",
    "work": "WORK_VAULT_PATH",
}


def get_workspaces() -> dict[str, Path]:
    """Return {name: path} for workspaces whose env var is set and path exists."""
    result = {}
    for name, env_var in WORKSPACES.items():
        value = os.environ.get(env_var)
        if value:
            p = Path(value).expanduser().resolve()
            if p.exists():
                result[name] = p
    return result


def select_workspace(workspaces: dict[str, Path]) -> Path | None:
    """Interactive workspace picker via stdin."""
    names = list(workspaces.keys())
    print("Available workspaces:")
    for i, name in enumerate(names, 1):
        print(f"  {i}) {name} — {workspaces[name]}")
    print()
    try:
        choice = input(f"Select workspace [1-{len(names)}]: ").strip()
    except (EOFError, KeyboardInterrupt):
        print()
        return None
    if not choice.isdigit() or not (1 <= int(choice) <= len(names)):
        print(f"Invalid choice: {choice}")
        return None
    return workspaces[names[int(choice) - 1]]


# ── Parse arguments ──────────────────────────────────────────────────────────

def parse_args():
    parser = argparse.ArgumentParser(description="Generate Obsidian vault graph")
    parser.add_argument("vault", nargs="?", help="Path to your vault directory")
    parser.add_argument("-w", "--workspace", help="Select workspace by name (personal, work)")
    parser.add_argument("--all", action="store_true", help="Scan all workspaces with in-browser selector")
    parser.add_argument("--active", help="Default active workspace when using --all")
    parser.add_argument("--list", action="store_true", help="List available workspaces")
    parser.add_argument("--output", help="Output HTML file path (default: temp file)")
    parser.add_argument("--no-open", action="store_true", help="Don't open browser")
    return parser.parse_args()


# ── Scan vault ────────────────────────────────────────────────────────────────

WIKILINK_RE = re.compile(r'\[\[([^\]|#]+)(?:[|#][^\]]*)?\]\]')

def get_folder_group(path: Path, vault_root: Path) -> str:
    """Return top-level folder name for color coding."""
    try:
        relative = path.relative_to(vault_root)
        parts = relative.parts
        if len(parts) > 1:
            return parts[0]
        return "root"
    except ValueError:
        return "root"

def scan_vault(vault_root: Path):
    """Scan all .md files, extract wikilinks, build nodes + edges."""
    vault_root = vault_root.resolve()
    md_files = list(vault_root.rglob("*.md"))

    # Build a name → path map for resolving wikilinks
    name_to_path = {}
    for f in md_files:
        stem = f.stem.lower()
        if stem not in name_to_path:
            name_to_path[stem] = f

    nodes = {}
    links_raw = []

    for f in md_files:
        rel = str(f.relative_to(vault_root))
        node_id = rel
        group = get_folder_group(f, vault_root)

        try:
            content = f.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            content = ""

        # Count words roughly
        word_count = len(content.split())

        # Extract wikilinks
        wikilinks = WIKILINK_RE.findall(content)

        nodes[node_id] = {
            "id": node_id,
            "label": f.stem,
            "group": group,
            "words": word_count,
            "path": str(f),
            "links_out": len(wikilinks),
        }

        for target_name in wikilinks:
            target_key = target_name.strip().lower()
            # Try to resolve to a real file
            resolved = name_to_path.get(target_key)
            if resolved:
                target_id = str(resolved.relative_to(vault_root))
            else:
                # Unresolved link — still show as a ghost node
                target_id = f"__unresolved__/{target_name.strip()}"
                if target_id not in nodes:
                    nodes[target_id] = {
                        "id": target_id,
                        "label": target_name.strip(),
                        "group": "unresolved",
                        "words": 0,
                        "path": "",
                        "links_out": 0,
                    }

            if node_id != target_id:
                links_raw.append({"source": node_id, "target": target_id})

    # Deduplicate links
    seen = set()
    links = []
    for l in links_raw:
        key = (l["source"], l["target"])
        if key not in seen:
            seen.add(key)
            links.append(l)

    # Count backlinks
    backlink_count = defaultdict(int)
    for l in links:
        backlink_count[l["target"]] += 1
    for nid, node in nodes.items():
        node["links_in"] = backlink_count.get(nid, 0)

    return list(nodes.values()), links


# ── HTML template ─────────────────────────────────────────────────────────────

HTML_TEMPLATE = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Vault Graph</title>
<style>
  * { box-sizing: border-box; margin: 0; padding: 0; }
  body { background: #0d0d14; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; overflow: hidden; }
  #canvas { width: 100vw; height: 100vh; }

  /* Tooltip */
  #tooltip {
    position: absolute;
    background: #1a1a2e;
    border: 1px solid #7f77dd44;
    border-radius: 8px;
    padding: 8px 12px;
    font-size: 12px;
    color: #afa9ec;
    pointer-events: none;
    opacity: 0;
    transition: opacity .15s;
    max-width: 220px;
  }
  #tooltip .title { font-size: 13px; font-weight: 600; color: #ece9ff; margin-bottom: 4px; }
  #tooltip .meta { color: #7f77dd; font-size: 11px; }

  /* Controls */
  #controls {
    position: absolute;
    top: 16px;
    left: 16px;
    display: flex;
    flex-direction: column;
    gap: 8px;
  }
  #workspace-select, #search-box {
    background: #1a1a2e;
    border: 1px solid #7f77dd44;
    border-radius: 8px;
    padding: 7px 12px;
    color: #ece9ff;
    font-size: 13px;
    outline: none;
    width: 200px;
  }
  #workspace-select { cursor: pointer; }
  #workspace-select:focus, #search-box:focus { border-color: #7f77dd; }
  #search-box::placeholder { color: #534ab7; }

  /* Stats */
  #stats {
    position: absolute;
    bottom: 16px;
    left: 16px;
    color: #534ab7;
    font-size: 11px;
    font-family: monospace;
    line-height: 1.8;
  }

  /* Legend */
  #legend {
    position: absolute;
    top: 16px;
    right: 16px;
    background: #1a1a2e;
    border: 1px solid #7f77dd22;
    border-radius: 8px;
    padding: 10px 14px;
    font-size: 11px;
    color: #7f77dd;
    min-width: 130px;
  }
  #legend .legend-title { color: #afa9ec; font-size: 12px; margin-bottom: 8px; font-weight: 600; }
  .legend-item { display: flex; align-items: center; gap: 7px; margin-bottom: 5px; }
  .legend-dot { width: 9px; height: 9px; border-radius: 50%; flex-shrink: 0; }

  /* Hint */
  #hint {
    position: absolute;
    bottom: 16px;
    right: 16px;
    color: #2a2a40;
    font-size: 11px;
    text-align: right;
    line-height: 1.8;
  }

  /* Reset button */
  #reset-btn {
    background: #1a1a2e;
    border: 1px solid #7f77dd44;
    border-radius: 8px;
    padding: 6px 12px;
    color: #7f77dd;
    font-size: 12px;
    cursor: pointer;
    transition: background .15s;
    width: 200px;
  }
  #reset-btn:hover { background: #2a2a44; }
</style>
</head>
<body>

<svg id="canvas"></svg>
<div id="tooltip"><div class="title"></div><div class="meta"></div></div>

<div id="controls">
  <select id="workspace-select"></select>
  <input id="search-box" type="text" placeholder="Search notes..." />
  <button id="reset-btn" onclick="resetView()">Reset view</button>
</div>

<div id="legend">
  <div class="legend-title">Folders</div>
  <div id="legend-items"></div>
</div>

<div id="stats"></div>
<div id="hint">drag · scroll to zoom · hover to highlight</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/d3/7.8.5/d3.min.js"></script>
<script>
const WORKSPACES_DATA = __WORKSPACES_DATA__;
const ACTIVE_WORKSPACE = "__ACTIVE_WORKSPACE__";

// ── Color palette ─────────────────────────────────────────────────────────
const PALETTE = [
  '#7f77dd', '#1d9e75', '#d85a30', '#ba7517',
  '#d4537e', '#378add', '#639922', '#888780',
  '#534ab7', '#0f6e56',
];

// ── State ─────────────────────────────────────────────────────────────────
let sim = null;

// ── Setup SVG ─────────────────────────────────────────────────────────────
const W = window.innerWidth, H = window.innerHeight;
const svg = d3.select('#canvas').attr('width', W).attr('height', H);
const gRoot = svg.append('g');

const zoom = d3.zoom().scaleExtent([0.1, 8]).on('zoom', e => gRoot.attr('transform', e.transform));
svg.call(zoom);

// ── Build workspace selector ──────────────────────────────────────────────
const wsSelect = document.getElementById('workspace-select');
const wsNames = Object.keys(WORKSPACES_DATA);

if (wsNames.length <= 1) {
  wsSelect.style.display = 'none';
}

wsNames.forEach(name => {
  const opt = document.createElement('option');
  opt.value = name;
  opt.textContent = name.charAt(0).toUpperCase() + name.slice(1);
  if (name === ACTIVE_WORKSPACE) opt.selected = true;
  wsSelect.appendChild(opt);
});

wsSelect.addEventListener('change', () => renderGraph(wsSelect.value));

// ── Node radius ───────────────────────────────────────────────────────────
function nodeR(d) {
  const total = (d.links_in || 0) + (d.links_out || 0);
  if (d.group === 'unresolved') return 3;
  return 4 + Math.min(total * 1.2, 12);
}

// ── Render graph ──────────────────────────────────────────────────────────
function renderGraph(wsName) {
  // Stop previous simulation
  if (sim) sim.stop();

  // Clear SVG content
  gRoot.selectAll('*').remove();

  // Reset zoom
  svg.call(zoom.transform, d3.zoomIdentity);

  // Deep-copy data so D3 mutation doesn't corrupt the source
  const data = WORKSPACES_DATA[wsName];
  const nodes = data.nodes.map(n => ({ ...n }));
  const links = data.links.map(l => ({ ...l }));

  // Build color map
  const GROUP_COLORS = {};
  const groups = [...new Set(nodes.map(n => n.group))].filter(g => g !== 'unresolved');
  groups.forEach((g, i) => { GROUP_COLORS[g] = PALETTE[i % PALETTE.length]; });
  GROUP_COLORS['unresolved'] = '#2a2a3e';

  // Legend
  const legendEl = document.getElementById('legend-items');
  legendEl.innerHTML = '';
  groups.forEach(grp => {
    const item = document.createElement('div');
    item.className = 'legend-item';
    item.innerHTML = `<div class="legend-dot" style="background:${GROUP_COLORS[grp]}"></div><span>${grp}</span>`;
    legendEl.appendChild(item);
  });
  if (GROUP_COLORS['unresolved']) {
    const item = document.createElement('div');
    item.className = 'legend-item';
    item.innerHTML = `<div class="legend-dot" style="background:#2a2a3e;border:1px solid #534ab7"></div><span style="color:#534ab7">unresolved</span>`;
    legendEl.appendChild(item);
  }

  // Stats
  const realNodes = nodes.filter(n => n.group !== 'unresolved');
  const statsEl = document.getElementById('stats');
  statsEl.innerHTML = `${wsName}<br>${realNodes.length} notes &nbsp;&middot;&nbsp; ${links.length} links`;

  // Simulation
  const curW = window.innerWidth, curH = window.innerHeight;
  sim = d3.forceSimulation(nodes)
    .force('link', d3.forceLink(links).id(d => d.id).distance(90).strength(0.35))
    .force('charge', d3.forceManyBody().strength(-250))
    .force('center', d3.forceCenter(curW / 2, curH / 2))
    .force('collide', d3.forceCollide(d => nodeR(d) + 6));

  // Links
  const linkEl = gRoot.append('g').selectAll('line')
    .data(links).join('line')
    .attr('stroke', '#7f77dd')
    .attr('stroke-opacity', 0.2)
    .attr('stroke-width', 1);

  // Nodes
  const nodeG = gRoot.append('g').selectAll('g')
    .data(nodes).join('g')
    .attr('cursor', d => d.group !== 'unresolved' ? 'pointer' : 'default')
    .call(d3.drag()
      .on('start', (e, d) => { if (!e.active) sim.alphaTarget(0.3).restart(); d.fx = d.x; d.fy = d.y; })
      .on('drag',  (e, d) => { d.fx = e.x; d.fy = e.y; })
      .on('end',   (e, d) => { if (!e.active) sim.alphaTarget(0); d.fx = null; d.fy = null; }));

  nodeG.append('circle')
    .attr('r', nodeR)
    .attr('fill', d => GROUP_COLORS[d.group] || '#534ab7')
    .attr('fill-opacity', d => d.group === 'unresolved' ? 0.3 : 0.85)
    .attr('stroke', d => GROUP_COLORS[d.group] || '#534ab7')
    .attr('stroke-opacity', d => d.group === 'unresolved' ? 0.3 : 0.6)
    .attr('stroke-width', 1.5);

  // Labels
  nodeG.append('text')
    .text(d => d.label)
    .attr('font-size', d => {
      const total = (d.links_in || 0) + (d.links_out || 0);
      return total > 4 ? 12 : 10;
    })
    .attr('fill', d => GROUP_COLORS[d.group] || '#534ab7')
    .attr('fill-opacity', 0.85)
    .attr('text-anchor', 'middle')
    .attr('dy', d => -(nodeR(d) + 5))
    .attr('pointer-events', 'none')
    .attr('class', 'node-label')
    .attr('opacity', d => {
      const total = (d.links_in || 0) + (d.links_out || 0);
      return total >= 3 ? 1 : 0;
    });

  // Tooltip
  const tip = document.getElementById('tooltip');

  nodeG.on('mouseover', function(e, d) {
    if (d.group === 'unresolved') return;

    const connected = new Set([d.id]);
    links.forEach(l => {
      if (l.source.id === d.id) connected.add(l.target.id);
      if (l.target.id === d.id) connected.add(l.source.id);
    });

    linkEl
      .attr('stroke-opacity', l => l.source.id === d.id || l.target.id === d.id ? 0.9 : 0.03)
      .attr('stroke-width',   l => l.source.id === d.id || l.target.id === d.id ? 2 : 0.8);
    nodeG.select('circle').attr('fill-opacity', n => connected.has(n.id) ? 1 : 0.1);
    nodeG.select('.node-label').attr('opacity', n => connected.has(n.id) ? 1 : 0);

    tip.querySelector('.title').textContent = d.label;
    tip.querySelector('.meta').innerHTML =
      `${d.group} &nbsp;&middot;&nbsp; ${d.links_in} &larr; &nbsp; ${d.links_out} &rarr;` +
      (d.words > 0 ? `<br>${d.words} words` : '');
    tip.style.opacity = 1;

  }).on('mousemove', e => {
    tip.style.left = (e.pageX + 14) + 'px';
    tip.style.top  = (e.pageY - 32) + 'px';
  }).on('mouseout', () => {
    linkEl.attr('stroke-opacity', 0.2).attr('stroke-width', 1);
    nodeG.select('circle').attr('fill-opacity', d => d.group === 'unresolved' ? 0.3 : 0.85);
    nodeG.select('.node-label').attr('opacity', d => {
      const total = (d.links_in || 0) + (d.links_out || 0);
      return total >= 3 ? 1 : 0;
    });
    tip.style.opacity = 0;
  });

  // Tick
  sim.on('tick', () => {
    linkEl
      .attr('x1', d => d.source.x).attr('y1', d => d.source.y)
      .attr('x2', d => d.target.x).attr('y2', d => d.target.y);
    nodeG.attr('transform', d => `translate(${d.x},${d.y})`);
  });

  // Search — rebind to current data
  const searchBox = document.getElementById('search-box');
  searchBox.value = '';
  // Remove old listener by replacing the element
  const newSearch = searchBox.cloneNode(true);
  searchBox.parentNode.replaceChild(newSearch, searchBox);

  newSearch.addEventListener('input', function() {
    const q = this.value.trim().toLowerCase();
    if (!q) {
      nodeG.select('circle').attr('fill-opacity', d => d.group === 'unresolved' ? 0.3 : 0.85);
      nodeG.select('.node-label').attr('opacity', d => {
        const total = (d.links_in || 0) + (d.links_out || 0);
        return total >= 3 ? 1 : 0;
      });
      linkEl.attr('stroke-opacity', 0.2);
      return;
    }

    const matched = new Set(nodes.filter(n => n.label.toLowerCase().includes(q)).map(n => n.id));
    nodeG.select('circle').attr('fill-opacity', d => matched.has(d.id) ? 1 : 0.05);
    nodeG.select('.node-label').attr('opacity', d => matched.has(d.id) ? 1 : 0);
    linkEl.attr('stroke-opacity', l =>
      matched.has(l.source.id) || matched.has(l.target.id) ? 0.7 : 0.02);
  });
}

// ── Reset view ────────────────────────────────────────────────────────────
function resetView() {
  svg.transition().duration(600).call(zoom.transform, d3.zoomIdentity);
}

// ── Resize ────────────────────────────────────────────────────────────────
window.addEventListener('resize', () => {
  const nw = window.innerWidth, nh = window.innerHeight;
  svg.attr('width', nw).attr('height', nh);
  if (sim) {
    sim.force('center', d3.forceCenter(nw / 2, nh / 2)).alpha(0.1).restart();
  }
});

// ── Initial render ────────────────────────────────────────────────────────
renderGraph(ACTIVE_WORKSPACE);
</script>
</body>
</html>
"""


# ── Generate HTML ─────────────────────────────────────────────────────────────

def generate_html(workspaces_data: dict, active: str) -> str:
    html = HTML_TEMPLATE
    html = html.replace("__WORKSPACES_DATA__", json.dumps(workspaces_data, ensure_ascii=False))
    html = html.replace("__ACTIVE_WORKSPACE__", active)
    return html


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    args = parse_args()
    workspaces = get_workspaces()

    # --list: show workspaces and exit
    if args.list:
        if not workspaces:
            print("No workspaces configured. Set PERSONAL_VAULT_PATH / WORK_VAULT_PATH env vars.")
            return 1
        print("Available workspaces:")
        for name, path in workspaces.items():
            print(f"  {name} — {path}")
        return 0

    # Build {name: path} map of vaults to scan
    vaults_to_scan: dict[str, Path] = {}
    active_name = ""

    if args.all:
        # Scan all configured workspaces
        if not workspaces:
            print("No workspaces configured. Set PERSONAL_VAULT_PATH / WORK_VAULT_PATH env vars.")
            return 1
        vaults_to_scan = workspaces
        active_name = args.active if args.active and args.active in workspaces else list(workspaces.keys())[0]
    elif args.vault:
        vault = Path(args.vault).expanduser().resolve()
        if not vault.exists():
            print(f"Error: vault path does not exist: {vault}")
            return 1
        # Check if it matches a known workspace, include all if so
        matched_name = None
        for name, ws_path in workspaces.items():
            if vault == ws_path:
                matched_name = name
                break
        if matched_name and len(workspaces) > 1:
            vaults_to_scan = workspaces
            active_name = matched_name
        else:
            name = matched_name or vault.name
            vaults_to_scan = {name: vault}
            active_name = name
    elif args.workspace:
        if args.workspace not in workspaces:
            print(f"Error: workspace '{args.workspace}' not found.")
            if workspaces:
                print(f"Available: {', '.join(workspaces.keys())}")
            else:
                print("Set PERSONAL_VAULT_PATH / WORK_VAULT_PATH env vars.")
            return 1
        # Include all workspaces, default to the selected one
        if len(workspaces) > 1:
            vaults_to_scan = workspaces
        else:
            vaults_to_scan = {args.workspace: workspaces[args.workspace]}
        active_name = args.workspace
    elif workspaces:
        if len(workspaces) == 1:
            name, path = next(iter(workspaces.items()))
            vaults_to_scan = {name: path}
            active_name = name
        else:
            # Interactive picker, but still include all in the HTML
            selected = select_workspace(workspaces)
            if selected is None:
                return 1
            vaults_to_scan = workspaces
            for name, path in workspaces.items():
                if path == selected:
                    active_name = name
                    break
    else:
        print("Error: no vault path given and no workspaces configured.")
        print("Usage: vault-graph.py <path> OR set PERSONAL_VAULT_PATH / WORK_VAULT_PATH env vars.")
        return 1

    # Scan all vaults
    workspaces_data = {}
    for name, vault_path in vaults_to_scan.items():
        if not vault_path.exists():
            print(f"Warning: skipping {name} — path does not exist: {vault_path}")
            continue
        print(f"Scanning {name}: {vault_path}")
        nodes, links = scan_vault(vault_path)
        real_count = sum(1 for n in nodes if n['group'] != 'unresolved')
        print(f"  {real_count} notes, {len(links)} links")
        workspaces_data[name] = {"nodes": nodes, "links": links}

    if not workspaces_data:
        print("Error: no valid vaults to scan.")
        return 1

    if active_name not in workspaces_data:
        active_name = next(iter(workspaces_data))

    html = generate_html(workspaces_data, active_name)

    if args.output:
        out_path = Path(args.output).expanduser()
    else:
        # Save to the common parent directory of all workspace paths
        all_paths = list(vaults_to_scan.values())
        root = Path(os.path.commonpath(all_paths))
        out_path = root / "graph.html"

    out_path.write_text(html, encoding="utf-8")

    print(f"Graph saved: {out_path}")

    if not args.no_open:
        webbrowser.open(f"file://{out_path}")
        print("Opening in browser...")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
