-- Regression checks for the perf/cleanup branch.
-- Run via: nvim --headless -l tests/check.lua

local failures = {}
local passes = 0

local function check(name, ok, detail)
  if ok then
    passes = passes + 1
    io.write("  ok  - " .. name .. "\n")
  else
    table.insert(failures, name .. (detail and (": " .. detail) or ""))
    io.write("  FAIL - " .. name .. (detail and (" (" .. detail .. ")") or "") .. "\n")
  end
end

-- Force lazy.nvim to settle so triggers like VeryLazy fire before we inspect state.
vim.cmd("doautocmd User VeryLazy")

local lazy_ok, lazy_config = pcall(require, "lazy.core.config")
if not lazy_ok then
  io.write("FATAL: lazy.core.config not available\n")
  os.exit(1)
end
local plugins = lazy_config.plugins

local function get(name)
  return plugins[name]
end

-- ─── 1. defaults.lazy is true ─────────────────────────────────────────────
check(
  "lazy.nvim defaults.lazy = true",
  lazy_config.options.defaults.lazy == true,
  "got " .. tostring(lazy_config.options.defaults.lazy)
)

-- ─── 2. Plugins that should be lazy ───────────────────────────────────────
local must_be_lazy = {
  "lualine.nvim",
  "nvim-notify",
  "dressing.nvim",
  "incline.nvim",
  "rainbow-delimiters.nvim",
  "nvim-tree.lua",
  "gitsigns.nvim",
  "nvim-lspconfig",
  "nvim-osc52",
}
for _, name in ipairs(must_be_lazy) do
  local p = get(name)
  if not p then
    check("lazy: " .. name .. " (registered)", false, "plugin not found in lazy spec")
  else
    check("lazy: " .. name, p.lazy == true, "p.lazy=" .. tostring(p.lazy))
  end
end

-- ─── 3. Plugins that must stay eager ──────────────────────────────────────
local must_be_eager = {
  "sonokai",
  "nvim-treesitter",
}
for _, name in ipairs(must_be_eager) do
  local p = get(name)
  if not p then
    check("eager: " .. name .. " (registered)", false, "plugin not found in lazy spec")
  else
    check("eager: " .. name, p.lazy == false, "p.lazy=" .. tostring(p.lazy))
  end
end

-- ─── 4. nvim-tree triggers ────────────────────────────────────────────────
do
  local p = get("nvim-tree.lua")
  local has_keys = p and p._.handlers and p._.handlers.keys ~= nil
  local has_cmd = p and p._.handlers and p._.handlers.cmd ~= nil
  check("nvim-tree has keys handler", has_keys == true)
  check("nvim-tree has cmd handler", has_cmd == true)
end

-- ─── 5. Mason ensure_installed contains eslint-lsp ────────────────────────
do
  local mason = get("mason.nvim")
  local opts = mason and mason.opts or nil
  if type(opts) == "function" then
    opts = opts(mason, {})
  end
  local list = opts and opts.ensure_installed or {}
  local found = false
  for _, tool in ipairs(list) do
    if tool == "eslint-lsp" then
      found = true
      break
    end
  end
  check("mason ensure_installed contains eslint-lsp", found, "list=" .. vim.inspect(list))
end

-- ─── 6. snacks.dashboard disabled ─────────────────────────────────────────
do
  local snacks = get("snacks.nvim")
  local opts = snacks and snacks.opts or {}
  if type(opts) == "function" then
    opts = opts(snacks, {}) or {}
  end
  local dashboard = opts.dashboard or {}
  check("snacks.dashboard.enabled = false", dashboard.enabled == false, "got " .. tostring(dashboard.enabled))
end

-- ─── 7. LSP inlay hints disabled ──────────────────────────────────────────
do
  local lspconfig = get("nvim-lspconfig")
  local opts_fn = lspconfig and lspconfig.opts or nil
  local opts = type(opts_fn) == "function" and opts_fn() or opts_fn or {}
  local inlay_enabled = opts.inlay_hints and opts.inlay_hints.enabled
  check("lsp inlay_hints.enabled = false", inlay_enabled == false, "got " .. tostring(inlay_enabled))

  -- functionLikeReturnTypes also disabled
  local ts = opts.servers and opts.servers.vtsls and opts.servers.vtsls.settings
  local hints = ts and ts.typescript and ts.typescript.inlayHints
  local fn_returns = hints and hints.functionLikeReturnTypes and hints.functionLikeReturnTypes.enabled
  check(
    "vtsls functionLikeReturnTypes.enabled = false",
    fn_returns == false,
    "got " .. tostring(fn_returns)
  )
end

-- ─── 8. autocmds.lua: BufRead duplicates removed ─────────────────────────
do
  -- Old config registered TWO BufRead autocmds with pattern "*.ts,*.js,*.sh,*.json,*.yml,*.lua".
  -- The consolidation moves them to a single FileType autocmd, so no BufRead
  -- autocmd with that exact glob pattern should remain.
  local bad_pattern = "*.ts,*.js,*.sh,*.json,*.yml,*.lua"
  local cmds = vim.api.nvim_get_autocmds({ event = "BufRead" })
  local stale = 0
  for _, ac in ipairs(cmds) do
    if (ac.pattern or "") == bad_pattern then
      stale = stale + 1
    end
  end
  check("no stale BufRead autocmd with old pattern", stale == 0, "found " .. stale)

  -- The consolidated autocmd uses pattern = { "typescript", "javascript", "sh", "bash", "json", "yaml", "lua" }.
  -- nvim_get_autocmds returns one entry per pattern; check our patterns each have a registered FileType autocmd.
  local needed = { "typescript", "javascript", "sh", "bash", "json", "yaml", "lua" }
  local present = {}
  for _, ac in ipairs(vim.api.nvim_get_autocmds({ event = "FileType" })) do
    if ac.pattern then
      present[ac.pattern] = true
    end
  end
  local missing = {}
  for _, ft in ipairs(needed) do
    if not present[ft] then
      table.insert(missing, ft)
    end
  end
  check(
    "consolidated FileType autocmds present (all 7 patterns)",
    #missing == 0,
    "missing: " .. table.concat(missing, ",")
  )
end

-- ─── 9. nvim-tree no longer auto-opens ────────────────────────────────────
do
  -- The auto-open block was: if vim.fn.argc(-1) == 0 then NvimTreeFocus end
  -- After the fix, that block is gone, so :NvimTree* shouldn't fire on startup.
  -- We assert by checking the file content for the removed snippet.
  local f = io.open("lua/plugins/editor/nvim_tree.lua", "r")
  local src = f and f:read("*a") or ""
  if f then f:close() end
  local has_auto_open = src:find('vim%.fn%.argc%(%-1%)') ~= nil
  check("nvim-tree auto-open block removed", not has_auto_open)
end

-- ─── 10. tmux-agent spec registered and lazy ──────────────────────────────
do
  -- The TMUX Claude Code launchers (<leader>aa/ag/aS/aV) live in their own
  -- local lazy spec (lua/plugins/ai/tmux-agent.lua), registered via dir/keys.
  -- They must stay lazy and load on keypress, not eagerly at startup.
  local p = get("tmux-agent")
  if not p then
    check("tmux-agent (registered)", false, "plugin not found in lazy spec")
  else
    check("lazy: tmux-agent", p.lazy == true, "p.lazy=" .. tostring(p.lazy))
    local has_keys = p._ and p._.handlers and p._.handlers.keys ~= nil
    check("tmux-agent has keys handler", has_keys == true)
  end
end

-- ─── Summary ──────────────────────────────────────────────────────────────
io.write(string.format("\n%d passed, %d failed\n", passes, #failures))
if #failures > 0 then
  for _, f in ipairs(failures) do
    io.write("  - " .. f .. "\n")
  end
  os.exit(1)
end
os.exit(0)
