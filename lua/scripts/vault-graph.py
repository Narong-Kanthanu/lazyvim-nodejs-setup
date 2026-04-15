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
import subprocess
import sys
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
  body { background: #1a2332; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; overflow: hidden; }
  #network-container { width: 100vw; height: 100vh; }

  /* Tooltip */
  #tooltip {
    position: absolute;
    background: #152030;
    border: 1px solid #3a5a6a44;
    border-radius: 8px;
    padding: 8px 12px;
    font-size: 12px;
    color: #a0b8c8;
    pointer-events: none;
    opacity: 0;
    transition: opacity .15s;
    max-width: 220px;
    z-index: 10;
  }
  #tooltip .title { font-size: 13px; font-weight: 600; color: #cdd3da; margin-bottom: 4px; }
  #tooltip .meta { color: #79a8eb; font-size: 11px; }

  /* Controls */
  #controls {
    position: absolute;
    top: 16px;
    left: 16px;
    display: flex;
    flex-direction: column;
    gap: 8px;
    z-index: 5;
  }
  #workspace-select, #search-box {
    background: #152030;
    border: 1px solid #3a5a6a44;
    border-radius: 8px;
    padding: 7px 12px;
    color: #cdd3da;
    font-size: 13px;
    outline: none;
    width: 200px;
  }
  #workspace-select { cursor: pointer; }
  #workspace-select:focus, #search-box:focus { border-color: #79a8eb; }
  #search-box::placeholder { color: #4a6a7a; }

  /* Stats */
  #stats {
    position: absolute;
    bottom: 16px;
    left: 16px;
    color: #4a6a7a;
    font-size: 11px;
    font-family: monospace;
    line-height: 1.8;
    z-index: 5;
  }

  /* Legend */
  #legend {
    position: absolute;
    top: 16px;
    right: 16px;
    background: #152030;
    border: 1px solid #3a5a6a22;
    border-radius: 8px;
    padding: 10px 14px;
    font-size: 11px;
    color: #79a8eb;
    min-width: 130px;
    z-index: 5;
  }
  #legend .legend-title { color: #a0b8c8; font-size: 12px; margin-bottom: 8px; font-weight: 600; }
  .legend-item { display: flex; align-items: center; gap: 7px; margin-bottom: 5px; }
  .legend-dot { width: 9px; height: 9px; border-radius: 50%; flex-shrink: 0; }

  /* Hint */
  #hint {
    position: absolute;
    bottom: 16px;
    right: 16px;
    color: #2a3a4a;
    font-size: 11px;
    text-align: right;
    line-height: 1.8;
    z-index: 5;
  }

  /* Reset button */
  #reset-btn {
    background: #152030;
    border: 1px solid #3a5a6a44;
    border-radius: 8px;
    padding: 6px 12px;
    color: #79a8eb;
    font-size: 12px;
    cursor: pointer;
    transition: background .15s;
    width: 200px;
  }
  #reset-btn:hover { background: #1e3040; }
</style>
</head>
<body>

<div id="network-container"></div>
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
<div id="hint">drag · scroll to zoom · hover to highlight · click to focus</div>

<script src="https://cdn.jsdelivr.net/npm/vis-network@9.1.9/standalone/umd/vis-network.min.js"></script>
<script>
const WORKSPACES_DATA = __WORKSPACES_DATA__;
const ACTIVE_WORKSPACE = "__ACTIVE_WORKSPACE__";

// ── Color palette (Obsidian-style: yellow-green, teal, blue tones) ────────
const PALETTE = [
  '#c8d84e', '#4ecdc4', '#79a8eb', '#a882ff',
  '#e8d44d', '#56c1b3', '#6bb5e0', '#d4a0e0',
  '#8ecf65', '#45b7d1',
];

// ── State ─────────────────────────────────────────────────────────────────
let network = null;
let nodesDS = null;
let edgesDS = null;
let GROUP_COLORS = {};
let focusedNode = null;
let searchActive = false;
let savedSearchQuery = '';
const container = document.getElementById('network-container');

// ── vis.js options ────────────────────────────────────────────────────────
const options = {
  physics: {
    solver: 'barnesHut',
    barnesHut: {
      gravitationalConstant: -2500,
      centralGravity: 0.3,
      springLength: 95,
      springConstant: 0.04,
      damping: 0.09,
      avoidOverlap: 0.1,
    },
    stabilization: { iterations: 150 },
  },
  interaction: {
    hover: true,
    tooltipDelay: 100,
    dragNodes: true,
    dragView: true,
    zoomView: true,
    zoomSpeed: 0.6,
  },
  nodes: {
    shape: 'dot',
    borderWidth: 0,
    shadow: { enabled: true, size: 12, x: 0, y: 0 },
    font: { face: '-apple-system, BlinkMacSystemFont, Segoe UI, sans-serif' },
  },
  edges: {
    smooth: false,
    color: { inherit: false },
    width: 0.5,
  },
};

// ── Node size helper ──────────────────────────────────────────────────────
function nodeSize(n) {
  const total = (n.links_in || 0) + (n.links_out || 0);
  if (n.group === 'unresolved') return 2;
  return 3 + Math.min(total * 0.8, 8);
}

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

// ── Render graph ──────────────────────────────────────────────────────────
function renderGraph(wsName) {
  if (network) { network.destroy(); network = null; }

  const data = WORKSPACES_DATA[wsName];

  // Build color map
  GROUP_COLORS = {};
  const groups = [...new Set(data.nodes.map(n => n.group))].filter(g => g !== 'unresolved');
  groups.forEach((g, i) => { GROUP_COLORS[g] = PALETTE[i % PALETTE.length]; });
  GROUP_COLORS['unresolved'] = '#2a3a4a';

  // Legend
  const legendEl = document.getElementById('legend-items');
  legendEl.innerHTML = '';
  groups.forEach(grp => {
    const item = document.createElement('div');
    item.className = 'legend-item';
    item.innerHTML = '<div class="legend-dot" style="background:' + GROUP_COLORS[grp] + '"></div><span>' + grp + '</span>';
    legendEl.appendChild(item);
  });
  const unresolvedItem = document.createElement('div');
  unresolvedItem.className = 'legend-item';
  unresolvedItem.innerHTML = '<div class="legend-dot" style="background:#2a3a4a;border:1px solid #4a6a7a"></div><span style="color:#4a6a7a">unresolved</span>';
  legendEl.appendChild(unresolvedItem);

  // Stats
  const realNodes = data.nodes.filter(n => n.group !== 'unresolved');
  document.getElementById('stats').innerHTML = wsName + '<br>' + realNodes.length + ' notes &nbsp;&middot;&nbsp; ' + data.links.length + ' links';

  // Build vis.js datasets
  const visNodes = data.nodes.map(n => {
    const total = (n.links_in || 0) + (n.links_out || 0);
    const color = GROUP_COLORS[n.group] || '#4a6a7a';
    const isUnresolved = n.group === 'unresolved';
    return {
      id: n.id,
      label: total >= 3 ? n.label : undefined,
      size: nodeSize(n),
      color: {
        background: color,
        border: color,
        highlight: { background: '#ffffff', border: '#ffffff' },
        hover: { background: '#ffffff', border: '#ffffff' },
      },
      opacity: isUnresolved ? 0.25 : 0.9,
      shadow: { enabled: !isUnresolved, color: color + '80', size: 8 + Math.min(total * 2, 16), x: 0, y: 0 },
      font: {
        color: '#cdd3da',
        size: total > 4 ? 11 : 9,
        strokeWidth: 2,
        strokeColor: '#1a2332',
        vadjust: -(nodeSize(n) + 4),
      },
      // Metadata for hover/search
      _label: n.label,
      _group: n.group,
      _color: color,
      _links_in: n.links_in || 0,
      _links_out: n.links_out || 0,
      _words: n.words || 0,
      _total: total,
    };
  });

  const visEdges = data.links.map((l, i) => ({
    id: 'e' + i,
    from: l.source,
    to: l.target,
    color: { color: '#3a5a63', opacity: 0.35 },
    width: 0.5,
  }));

  nodesDS = new vis.DataSet(visNodes);
  edgesDS = new vis.DataSet(visEdges);

  network = new vis.Network(container, { nodes: nodesDS, edges: edgesDS }, options);

  // ── Hover highlight ──────────────────────────────────────────────────
  const tip = document.getElementById('tooltip');

  function resetHover() {
    tip.style.opacity = 0;
    nodesDS.update(nodesDS.get().map(n => ({
      id: n.id,
      opacity: n._group === 'unresolved' ? 0.25 : 0.9,
      label: n._total >= 3 ? n._label : undefined,
    })));
    edgesDS.update(edgesDS.get().map(e => ({
      id: e.id,
      color: { color: '#3a5a63', opacity: 0.35 },
      width: 0.5,
    })));
  }

  network.on('hoverNode', function(params) {
    if (searchActive || focusedNode) return;
    const nodeId = params.node;
    const nd = nodesDS.get(nodeId);
    if (nd._group === 'unresolved') return;

    const connNodes = new Set([nodeId, ...network.getConnectedNodes(nodeId)]);
    const connEdges = new Set(network.getConnectedEdges(nodeId));

    nodesDS.update(nodesDS.get().map(n => ({
      id: n.id,
      opacity: connNodes.has(n.id) ? 1 : 0.08,
      label: connNodes.has(n.id) ? n._label : undefined,
    })));

    edgesDS.update(edgesDS.get().map(e => ({
      id: e.id,
      color: { color: connEdges.has(e.id) ? '#79a8eb' : '#3a5a6a', opacity: connEdges.has(e.id) ? 0.8 : 0.03 },
      width: connEdges.has(e.id) ? 1.5 : 0.3,
    })));

    tip.querySelector('.title').textContent = nd._label;
    tip.querySelector('.meta').innerHTML =
      nd._group + ' &nbsp;&middot;&nbsp; ' + nd._links_in + ' &larr; &nbsp; ' + nd._links_out + ' &rarr;' +
      (nd._words > 0 ? '<br>' + nd._words + ' words' : '');
    tip.style.opacity = 1;
  });

  network.on('blurNode', function() {
    if (searchActive || focusedNode) return;
    nodesDS.update(nodesDS.get().map(n => ({
      id: n.id,
      opacity: n._group === 'unresolved' ? 0.25 : 0.9,
      label: n._total >= 3 ? n._label : undefined,
    })));

    edgesDS.update(edgesDS.get().map(e => ({
      id: e.id,
      color: { color: '#3a5a63', opacity: 0.35 },
      width: 0.5,
    })));

    tip.style.opacity = 0;
  });

  // Position tooltip via mouse
  container.addEventListener('mousemove', function(e) {
    tip.style.left = (e.pageX + 14) + 'px';
    tip.style.top = (e.pageY - 32) + 'px';
  });

  // ── Search ───────────────────────────────────────────────────────────
  const searchBox = document.getElementById('search-box');
  searchBox.value = '';
  const newSearch = searchBox.cloneNode(true);
  searchBox.parentNode.replaceChild(newSearch, searchBox);

  function applySearch(q) {
    // Find matched nodes and all their connected neighbors
    const directMatched = nodesDS.get().filter(n => n._label.toLowerCase().includes(q));
    const matchedIds = new Set(directMatched.map(n => n.id));
    const visibleNodes = new Set(matchedIds);
    const visibleEdges = new Set();

    matchedIds.forEach(id => {
      network.getConnectedNodes(id).forEach(nid => visibleNodes.add(nid));
      network.getConnectedEdges(id).forEach(eid => visibleEdges.add(eid));
    });

    // Hide non-related, show matched + connections with labels
    nodesDS.update(nodesDS.get().map(n => ({
      id: n.id,
      hidden: !visibleNodes.has(n.id),
      opacity: matchedIds.has(n.id) ? 1 : (visibleNodes.has(n.id) ? 0.6 : 0),
      label: visibleNodes.has(n.id) ? n._label : undefined,
      font: visibleNodes.has(n.id) ? {
        color: matchedIds.has(n.id) ? '#ffffff' : '#cdd3da',
        size: matchedIds.has(n.id) ? 13 : 11,
        strokeWidth: 2, strokeColor: '#1a2332',
        vadjust: -(nodeSize(n) + 4),
      } : n.font,
    })));

    edgesDS.update(edgesDS.get().map(e => ({
      id: e.id,
      hidden: !visibleEdges.has(e.id),
      color: { color: '#79a8eb', opacity: visibleEdges.has(e.id) ? 0.6 : 0 },
      width: visibleEdges.has(e.id) ? 1.2 : 0,
    })));

    // Zoom to fit visible nodes
    if (visibleNodes.size > 0) {
      network.fit({
        nodes: [...visibleNodes],
        animation: { duration: 400, easingFunction: 'easeInOutQuad' },
      });
    }
  }

  function restoreNormal() {
    searchActive = false;
    savedSearchQuery = '';
    newSearch.value = '';
    tip.style.opacity = 0;
    nodesDS.update(nodesDS.get().map(n => ({
      id: n.id,
      hidden: false,
      opacity: n._group === 'unresolved' ? 0.25 : 0.9,
      label: n._total >= 3 ? n._label : undefined,
      font: { color: '#cdd3da', size: n._total > 4 ? 11 : 9, strokeWidth: 2, strokeColor: '#1a2332', vadjust: -(nodeSize(n) + 4) },
    })));
    edgesDS.update(edgesDS.get().map(e => ({
      id: e.id,
      hidden: false,
      color: { color: '#3a5a63', opacity: 0.35 },
      width: 0.5,
    })));
    network.fit({ animation: { duration: 500, easingFunction: 'easeInOutQuad' } });
  }

  newSearch.addEventListener('input', function() {
    const q = this.value.trim().toLowerCase();
    if (!q) {
      restoreNormal();
      return;
    }
    resetHover();
    searchActive = true;
    savedSearchQuery = q;
    applySearch(q);
  });

  // ── Focus mode (click node to zoom, click background to exit) ────────
  function enterFocus(nodeId) {
    focusedNode = nodeId;
    const nd = nodesDS.get(nodeId);
    if (!nd || nd._group === 'unresolved') return;

    const connNodes = new Set([nodeId, ...network.getConnectedNodes(nodeId)]);
    const connEdges = new Set(network.getConnectedEdges(nodeId));

    // Show connected nodes with labels, hide the rest
    nodesDS.update(nodesDS.get().map(n => {
      const visible = connNodes.has(n.id);
      return {
        id: n.id,
        hidden: !visible,
        label: visible ? n._label : undefined,
        opacity: visible ? 1 : 0,
        font: visible ? { color: '#cdd3da', size: n.id === nodeId ? 14 : 12, strokeWidth: 2, strokeColor: '#1a2332' } : n.font,
      };
    }));

    edgesDS.update(edgesDS.get().map(e => ({
      id: e.id,
      hidden: !connEdges.has(e.id),
      color: { color: '#79a8eb', opacity: connEdges.has(e.id) ? 0.7 : 0 },
      width: connEdges.has(e.id) ? 1.5 : 0,
    })));

    // Zoom to fit the connected subgraph
    network.fit({
      nodes: [...connNodes],
      animation: { duration: 500, easingFunction: 'easeInOutQuad' },
    });
  }

  function exitFocus() {
    if (!focusedNode) return;
    focusedNode = null;

    // If search was active before focus, return to search results
    if (savedSearchQuery) {
      searchActive = true;
      applySearch(savedSearchQuery);
      return;
    }

    // Otherwise restore normal mode
    restoreNormal();
  }

  network.on('click', function(params) {
    if (params.nodes.length > 0) {
      // Clicked a node — enter focus (S2)
      // savedSearchQuery is already set if search was active
      searchActive = false;
      enterFocus(params.nodes[0]);
    } else {
      // Clicked empty space — step back one level
      if (focusedNode) {
        // S2 → S1 (if search was active) or S2 → Normal
        exitFocus();
      } else if (searchActive) {
        // S1 → Normal
        restoreNormal();
      }
    }
  });
}

// ── Reset view ────────────────────────────────────────────────────────────
function resetView() {
  if (network) network.fit({ animation: { duration: 600, easingFunction: 'easeInOutQuad' } });
}

// ── Resize ────────────────────────────────────────────────────────────────
window.addEventListener('resize', () => {
  if (network) network.redraw();
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


# ── Browser open / refresh ────────────────────────────────────────────────────

def open_or_refresh(file_path: Path):
    """Refresh existing browser tab if open, otherwise open a new one."""
    url = f"file://{file_path}"

    if sys.platform == "darwin":
        # Try Chrome first, then Safari, via AppleScript
        for browser, script in [
            ("Google Chrome", _chrome_applescript(url)),
            ("Safari", _safari_applescript(url)),
        ]:
            try:
                result = subprocess.run(
                    ["osascript", "-e", script],
                    capture_output=True, text=True, timeout=5,
                )
                if result.returncode == 0 and result.stdout.strip() == "found":
                    print(f"Refreshed in {browser}")
                    return
            except (subprocess.TimeoutExpired, FileNotFoundError):
                continue

    # Fallback: open new tab
    webbrowser.open(url)
    print("Opening in browser...")


def _chrome_applescript(url: str) -> str:
    return f'''
tell application "System Events"
    if not (exists process "Google Chrome") then return "missing"
end tell
tell application "Google Chrome"
    repeat with w in windows
        set ti to 0
        repeat with t in tabs of w
            set ti to ti + 1
            if URL of t starts with "{url}" then
                set active tab index of w to ti
                set index of w to 1
                tell t to reload
                return "found"
            end if
        end repeat
    end repeat
end tell
return "notfound"
'''


def _safari_applescript(url: str) -> str:
    return f'''
tell application "System Events"
    if not (exists process "Safari") then return "missing"
end tell
tell application "Safari"
    repeat with w in windows
        repeat with t in tabs of w
            if URL of t starts with "{url}" then
                set current tab of w to t
                set index of w to 1
                tell t to do JavaScript "location.reload()"
                return "found"
            end if
        end repeat
    end repeat
end tell
return "notfound"
'''


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
        open_or_refresh(out_path)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
