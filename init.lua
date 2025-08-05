-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Set bg of hl for floating
function SetHlForFloatingWindow()
  vim.api.nvim_set_hl(0, "NormalFloat", {
    link = "none",
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
  vim.api.nvim_set_hl(0, "TelescopeNormal", {
    bg = "none",
  })
  vim.api.nvim_set_hl(0, "TelescopeBorder", {
    bg = "none",
  })
end
SetHlForFloatingWindow()

-- Set fg of hl for window separator
function SetHlForWinSeparator()
  vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#b7bdf7" })
end
SetHlForWinSeparator()
