-- Resolve a node binary even when nvm isn't sourced in the GUI / launcher shell
-- that started Neovim. Order: $PATH → ~/.nvm/alias/default → highest installed
-- version under ~/.nvm/versions/node.
local function resolve_node_command()
  local exe = vim.fn.exepath("node")
  if exe ~= "" then
    return exe
  end

  local nvm_dir = vim.fn.expand("~/.nvm/versions/node")
  if vim.fn.isdirectory(nvm_dir) ~= 1 then
    return nil
  end

  local default_alias = vim.fn.expand("~/.nvm/alias/default")
  if vim.fn.filereadable(default_alias) == 1 then
    local lines = vim.fn.readfile(default_alias)
    local target = vim.trim(lines[1] or "")
    for _, name in ipairs({ target, "v" .. target }) do
      local candidate = nvm_dir .. "/" .. name .. "/bin/node"
      if vim.fn.executable(candidate) == 1 then
        return candidate
      end
    end
  end

  local versions = vim.fn.readdir(nvm_dir) or {}
  table.sort(versions, function(a, b)
    local function parse(v)
      local maj, min, pat = v:match("^v?(%d+)%.(%d+)%.(%d+)")
      return tonumber(maj) or 0, tonumber(min) or 0, tonumber(pat) or 0
    end
    local a1, a2, a3 = parse(a)
    local b1, b2, b3 = parse(b)
    if a1 ~= b1 then
      return a1 > b1
    end
    if a2 ~= b2 then
      return a2 > b2
    end
    return a3 > b3
  end)

  for _, v in ipairs(versions) do
    local candidate = nvm_dir .. "/" .. v .. "/bin/node"
    if vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end

  return nil
end

return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  build = ":Copilot auth",
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      copilot_node_command = resolve_node_command() or "node",
      suggestion = {
        enabled = not vim.g.ai_cmp,
        auto_trigger = false,
        hide_during_completion = true,
      },
      panel = {
        enabled = false,
      },
      filetypes = {
        ["*"] = true, -- default enabled all file types
      },
    })
  end,
}
