-- Remove line numbers in terminal buffer
vim.cmd("augroup terminalOpen")
vim.cmd("autocmd!")
vim.cmd("autocmd TermOpen * startinsert") -- starts in insert mode
vim.cmd("autocmd TermOpen * setlocal nonumber norelativenumber") -- no numbers
vim.cmd("autocmd TermEnter * setlocal signcolumn=no") -- no sign column
vim.cmd("augroup END")

-- Load setup diagnostic when create new buffer
function DiagnosticsConfig()
  vim.diagnostic.config({
    virtual_text = false, -- boolean | opts
    severity_sort = true,
    float = {
      source = true, -- "if_many" | boolean
    },
  })
end
vim.cmd("autocmd BufRead *.ts,*.sh,*.json,*.yml,*.lua lua DiagnosticsConfig()")
