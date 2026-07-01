local SESSION_NAME = "AI workspace"

local function in_tmux()
  if not vim.env.TMUX then
    vim.notify("Not inside tmux", vim.log.levels.WARN)
    return false
  end
  return true
end

local function configure_and_switch_session(session)
  vim.fn.system(table.concat({
    "tmux set-option -t " .. session .. " mouse on",
    "tmux set-option -t " .. session .. " detach-on-destroy off",
    "tmux switch-client -t " .. session,
  }, " && "))
end

-- Open a tmux window in the shared "AI workspace" session running `cmd`.
-- focus_existing: reuse a window with the same name instead of creating a new one.
local function open_window(name, cwd, cmd, focus_existing)
  if not in_tmux() then
    return
  end

  -- tmux rejects '.' and ':' in window names (reserved for session:window.pane targets),
  -- so a cwd like "flowaccount.dotnet.workspace" would make new-window fail silently.
  name = (name:gsub("[.:]", "."))

  local session = vim.fn.shellescape(SESSION_NAME)
  local n, c, run = vim.fn.shellescape(name), vim.fn.shellescape(cwd), vim.fn.shellescape(cmd)

  vim.fn.system("tmux has-session -t " .. session .. " 2>/dev/null")
  if vim.v.shell_error ~= 0 then
    vim.fn.system(("tmux new-session -d -s %s -n %s -c %s %s"):format(session, n, c, run))
  elseif focus_existing then
    local existing = vim.fn.system("tmux list-windows -t " .. session .. ' -F "#{window_name}" 2>/dev/null | grep -xF ' .. n)
    if vim.v.shell_error == 0 and existing ~= "" then
      vim.fn.system("tmux select-window -t " .. session .. ":" .. n)
    else
      vim.fn.system(("tmux new-window -t %s -n %s -c %s %s"):format(session, n, c, run))
    end
  else
    vim.fn.system(("tmux new-window -t %s -n %s -c %s %s"):format(session, n, c, run))
  end

  configure_and_switch_session(session)
end

-- Open a tmux split in the current window running `cmd`.
-- orientation: "-v" for a horizontal split (pane below), "-h" for a vertical split (pane beside).
local function open_split(orientation, cwd, cmd)
  if not in_tmux() then
    return
  end

  local c, run = vim.fn.shellescape(cwd), vim.fn.shellescape(cmd)
  vim.fn.jobstart(("tmux split-window %s -c %s %s"):format(orientation, c, run), { detach = false })
end

return {
  dir = vim.fn.stdpath("config"),
  name = "tmux-agent",
  keys = {
    {
      "<leader>aa",
      function()
        local cwd = vim.fn.getcwd()
        open_window("agents[ ]", cwd, "claude agents", true)
      end,
      desc = "New TMUX window with AI agent view",
      mode = { "n", "v" },
      silent = true,
    },
    {
      "<leader>ag",
      function()
        local cwd = vim.fn.getcwd()
        local dir = vim.fn.fnamemodify(cwd, ":t")
        local name = dir .. "[ ]"
        open_window(name, cwd, "claude --enable-auto-mode", false)
      end,
      desc = "New TMUX window with AI agent",
      mode = { "n", "v" },
      silent = true,
    },
    {
      "<leader>aS",
      function()
        local cwd = vim.fn.getcwd()
        open_split("-v", cwd, "claude --enable-auto-mode")
      end,
      desc = "New TMUX horizontal pane with AI agent",
      mode = { "n", "v" },
      silent = true,
    },
    {
      "<leader>aV",
      function()
        local cwd = vim.fn.getcwd()
        open_split("-h", cwd, "claude --enable-auto-mode")
      end,
      desc = "New TMUX vertical pane with AI agent",
      mode = { "n", "v" },
      silent = true,
    },
  },
}
