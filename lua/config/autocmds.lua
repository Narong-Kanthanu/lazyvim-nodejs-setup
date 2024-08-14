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
      border = "rounded",
    },
  })
end
vim.cmd("autocmd BufRead *.ts,*.js,*.sh,*.json,*.yml,*.lua lua DiagnosticsConfig()")

-- Load border bg color for nvim-cmp
vim.cmd("highlight! BorderBG guibg=#2A2A2A")

-- Set bg of hl for floating
function SetHlForFloatingWindow()
  vim.api.nvim_set_hl(0, "NormalFloat", {
    link = "Normal",
  })
  vim.api.nvim_set_hl(0, "FloatBorder", {
    bg = "none",
  })
  vim.api.nvim_set_hl(0, "DiagnosticError", {
    bg = "none",
  })
  vim.api.nvim_set_hl(0, "Float", {
    bg = "none",
  })
  vim.api.nvim_set_hl(0, "NvimFloat", {
    bg = "none",
  })
  vim.api.nvim_set_hl(0, "DiagnosticFloatingError", {
    bg = "none",
  })
  vim.api.nvim_set_hl(0, "CocDiagnosticError", {
    bg = "none",
  })
end
SetHlForFloatingWindow()
