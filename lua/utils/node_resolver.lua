-- Resolve a node binary even when nvm isn't sourced in the GUI / launcher
-- shell that started Neovim. Lookup order:
--   1. $PATH (`exepath`)
--   2. ~/.nvm/alias/default
--   3. highest installed version under ~/.nvm/versions/node
local M = {}

local function nvm_versions_dir()
  local dir = vim.fn.expand("~/.nvm/versions/node")
  if vim.fn.isdirectory(dir) ~= 1 then
    return nil
  end
  return dir
end

local function from_default_alias(nvm_dir)
  local alias = vim.fn.expand("~/.nvm/alias/default")
  if vim.fn.filereadable(alias) ~= 1 then
    return nil
  end
  local target = vim.trim((vim.fn.readfile(alias) or {})[1] or "")
  if target == "" then
    return nil
  end
  for _, name in ipairs({ target, "v" .. target }) do
    local candidate = nvm_dir .. "/" .. name .. "/bin/node"
    if vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end
  return nil
end

local function from_highest_version(nvm_dir)
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

--- Absolute path to a node executable, or nil if none can be found.
function M.resolve_command()
  local exe = vim.fn.exepath("node")
  if exe ~= "" then
    return exe
  end
  local nvm_dir = nvm_versions_dir()
  if not nvm_dir then
    return nil
  end
  return from_default_alias(nvm_dir) or from_highest_version(nvm_dir)
end

--- Directory containing the resolved node binary (also where `npm` lives), or nil.
function M.resolve_bin_dir()
  local cmd = M.resolve_command()
  if not cmd then
    return nil
  end
  return vim.fn.fnamemodify(cmd, ":h")
end

--- Prepend the resolved node bin dir to `vim.env.PATH` if not already present.
--- Lets child processes (e.g. Mason → npm) inherit it. Idempotent.
function M.ensure_on_path()
  local bin = M.resolve_bin_dir()
  if not bin then
    return
  end
  local path = vim.env.PATH or ""
  if not (":" .. path .. ":"):find(":" .. bin .. ":", 1, true) then
    vim.env.PATH = bin .. ":" .. path
  end
end

return M
