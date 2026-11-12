local SESSION_NAME = "AI workspace"
-- Nerd Font glyphs (written as escapes so they survive editors without the font).
-- Bracketed status icon appended (no space) to the end of the window name, only while
-- busy/waiting; an idle window shows no icon. tmux counts a Nerd Font glyph as one cell
-- but kitty draws many of them wider, so a wide glyph overlaps the closing "]". These
-- two were picked because they stay inside the brackets in the bold status line style;
-- check any replacement in kitty before switching.
local GLYPH_BUSY = "[\u{f070e}]" -- Claude is working
local GLYPH_WAITING = "[\u{f064d}]" -- Claude is waiting for a permission prompt

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

-- Window name format that follows the Claude Code session title. Claude Code writes its
-- session title (e.g. "✳ Fix login redirect") to the terminal title, which tmux stores
-- as #{pane_title}. The leading status glyph (✳ idle, ·✢✶✻✽ spinner frames) is stripped
-- and a status icon may be appended. Until Claude sets a title, pane_title is empty or
-- the hostname, so fall back to the cwd's basename.
-- The glyphs are listed explicitly rather than as [^[:alnum:]]: tmux reads the ':' in
-- [:alnum:] as a modifier separator, and an ASCII-only class would eat non-Latin titles.
-- The trailing "[<glyph>]" shows Claude's state from the @claude_status window option,
-- which the user-level Claude Code hook ~/.claude/hooks/tmux-claude-status.sh sets:
-- GLYPH_BUSY while busy, GLYPH_WAITING while waiting for permission, and nothing when
-- idle or unset.
local TITLE_FORMAT = table.concat({
  "#{?#{||:#{==:#{pane_title},},#{==:#{pane_title},#{host}}},",
  "#{b:pane_current_path},",
  "#{=40;s/^[·✢✳✶✻✽*]+ +//:pane_title}}",
  "#{?#{==:#{@claude_status},busy},",
  GLYPH_BUSY,
  ",#{?#{==:#{@claude_status},waiting},",
  GLYPH_WAITING,
  ",}}",
})

-- `new-window -n` disables automatic-rename for that window; turn it back on with a
-- format that tracks the pane title so the name follows the Claude session title.
local function follow_pane_title(window_id)
  local w = vim.fn.shellescape(window_id)
  vim.fn.system(table.concat({
    "tmux set-option -w -t " .. w .. " automatic-rename-format " .. vim.fn.shellescape(TITLE_FORMAT),
    "tmux set-option -w -t " .. w .. " automatic-rename on",
  }, " && "))
end

-- Open a tmux window in the shared "AI workspace" session running `cmd`.
-- opts.focus_existing: reuse a window with the same name instead of creating a new one.
-- opts.follow_title: rename the window to the Claude Code session title as it changes.
local function open_window(name, cwd, cmd, opts)
  opts = opts or {}
  if not in_tmux() then
    return
  end

  -- tmux rejects '.' and ':' in window names (reserved for session:window.pane targets),
  -- so a cwd like "flowaccount.dotnet.workspace" would make new-window fail silently.
  name = (name:gsub("[.:]", "-"))

  local session = vim.fn.shellescape(SESSION_NAME)
  local n, c, run = vim.fn.shellescape(name), vim.fn.shellescape(cwd), vim.fn.shellescape(cmd)
  local print_id = " -P -F '#{window_id}'"
  local window_id

  vim.fn.system("tmux has-session -t " .. session .. " 2>/dev/null")
  if vim.v.shell_error ~= 0 then
    window_id = vim.fn.system(("tmux new-session -d -s %s -n %s -c %s%s %s"):format(session, n, c, print_id, run))
  elseif opts.focus_existing then
    local existing = vim.fn.system("tmux list-windows -t " .. session .. ' -F "#{window_name}" 2>/dev/null | grep -xF ' .. n)
    if vim.v.shell_error == 0 and existing ~= "" then
      vim.fn.system("tmux select-window -t " .. session .. ":" .. n)
    else
      window_id = vim.fn.system(("tmux new-window -t %s -n %s -c %s%s %s"):format(session, n, c, print_id, run))
    end
  else
    window_id = vim.fn.system(("tmux new-window -t %s -n %s -c %s%s %s"):format(session, n, c, print_id, run))
  end

  window_id = window_id and vim.trim(window_id) or ""
  if opts.follow_title and vim.v.shell_error == 0 and window_id:match("^@%d+$") then
    follow_pane_title(window_id)
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
        open_window("agents", cwd, "claude agents", { focus_existing = true })
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
        open_window(dir, cwd, "claude --enable-auto-mode", { follow_title = true })
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
