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
function DisableInlayHints()
  vim.lsp.inlay_hint.enable(false, { bufnr = 0 })
end
vim.cmd("autocmd BufRead *.ts,*.js,*.sh,*.json,*.yml,*.lua lua DisableInlayHints()")

-- Very yank to go to the system clipboard automatically
vim.cmd("autocmd TextYankPost * lua require('osc52').copy_register('+')")
