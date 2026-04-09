-- Compact floating confirm dialog for unsaved changes
-- Replaces vim's built-in confirm dialog with a minimal centered popup
local function confirm_save(on_yes, on_no)
  local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
  if filename == "" then
    filename = "[No Name]"
  end

  local title = ' Save changes to "' .. filename .. '"? '
  local choices = "[Y]es  [N]o  [C]ancel"
  local width = math.max(#title + 2, #choices + 4)
  local pad = string.rep(" ", math.floor((width - #choices) / 2))

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { pad .. choices })
  vim.bo[buf].modifiable = false

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = 1,
    row = math.floor((vim.o.lines - 1) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = title,
    title_pos = "center",
  })

  local function close(callback)
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
    if callback then
      vim.schedule(callback)
    end
  end

  for key, cb in pairs({ y = on_yes, n = on_no }) do
    vim.keymap.set("n", key, function() close(cb) end, { buffer = buf, nowait = true })
  end
  for _, key in ipairs({ "c", "<Esc>" }) do
    vim.keymap.set("n", key, function() close() end, { buffer = buf, nowait = true })
  end
end

vim.api.nvim_create_user_command("ConfirmQuit", function(args)
  if args.bang or not vim.bo.modified then
    vim.cmd("quit" .. (args.bang and "!" or ""))
    return
  end
  confirm_save(function()
    vim.cmd("write | quit")
  end, function()
    vim.cmd("quit!")
  end)
end, { bang = true })

vim.api.nvim_create_user_command("ConfirmQall", function(args)
  if args.bang then
    vim.cmd("qall!")
    return
  end
  local modified = vim.tbl_filter(function(b)
    return vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buflisted and vim.bo[b].modified
  end, vim.api.nvim_list_bufs())
  if #modified == 0 then
    vim.cmd("qall")
    return
  end
  confirm_save(function()
    vim.cmd("wall | qall")
  end, function()
    vim.cmd("qall!")
  end)
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
