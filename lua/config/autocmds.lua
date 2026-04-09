-- Custom confirm dialog: compact floating popup with [Y]es [N]o [C]ancel
local function confirm_save(on_yes, on_no)
  local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
  local title = string.format(' Save changes to "%s"? ', name ~= "" and name or "[No Name]")
  local choices = "[Y]es  [N]o  [C]ancel"
  local w = math.max(#title + 2, #choices + 4)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { string.rep(" ", math.floor((w - #choices) / 2)) .. choices })
  vim.bo[buf].modifiable = false

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor", style = "minimal", border = "rounded",
    width = w, height = 1,
    row = math.floor((vim.o.lines - 1) / 2), col = math.floor((vim.o.columns - w) / 2),
    title = title, title_pos = "center",
  })

  local function close(cb)
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
    if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
    if cb then vim.schedule(cb) end
  end

  local map = function(key, cb) vim.keymap.set("n", key, function() close(cb) end, { buffer = buf, nowait = true }) end
  map("y", on_yes)
  map("n", on_no)
  map("c", nil)
  map("<Esc>", nil)
end

local function has_modified_bufs()
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buflisted and vim.bo[b].modified then return true end
  end
  return false
end

vim.api.nvim_create_user_command("ConfirmQuit", function(a)
  if a.bang or not vim.bo.modified then return vim.cmd("quit" .. (a.bang and "!" or "")) end
  confirm_save(function() vim.cmd("write | quit") end, function() vim.cmd("quit!") end)
end, { bang = true })

vim.api.nvim_create_user_command("ConfirmQall", function(a)
  if a.bang or not has_modified_bufs() then return vim.cmd("qall" .. (a.bang and "!" or "")) end
  confirm_save(function() vim.cmd("wall | qall") end, function() vim.cmd("qall!") end)
end, { bang = true })

vim.cmd([[cnoreabbrev <expr> q  getcmdtype() == ':' && getcmdline() ==# 'q'  ? 'ConfirmQuit'  : 'q']])
vim.cmd([[cnoreabbrev <expr> qa getcmdtype() == ':' && getcmdline() ==# 'qa' ? 'ConfirmQall' : 'qa']])

-- Remove line numbers in terminal buffer
vim.cmd("augroup terminalOpen")
vim.cmd("autocmd!")
vim.cmd("autocmd TermOpen * startinsert") -- starts in insert mode
vim.cmd("autocmd TermOpen * setlocal nonumber norelativenumber") -- no numbers
vim.cmd("autocmd TermEnter * setlocal signcolumn=no") -- no sign column
vim.cmd("augroup END")

-- Load border bg color for nvim-cmp
vim.cmd("highlight! BorderBG guibg=#2a2a2a")

-- Load setup diagnostic when create new buffer
function DiagnosticsConfig()
  vim.diagnostic.config({
    virtual_text = false, -- boolean | opts
    severity_sort = true,
    float = {
      source = true, -- "if_many" | boolean
      border = "rounded",
    },
  })
end
vim.cmd("autocmd BufRead *.ts,*.js,*.sh,*.json,*.yml,*.lua lua DiagnosticsConfig()")

-- Disable inlay hints for some filetypes
vim.api.nvim_create_autocmd("BufRead", {
  pattern = { "*.ts", "*.js", "*.sh", "*.json", "*.yml", "*.lua" },
  callback = function()
    vim.lsp.inlay_hint.enable(false, { bufnr = 0 })
  end,
})

-- Enable lazyredraw during macro recording and execution
vim.cmd([[
  augroup LazyRedrawMacro
    autocmd!
    autocmd RecordingEnter * set lazyredraw
    autocmd RecordingLeave * set nolazyredraw
  augroup END
]])
