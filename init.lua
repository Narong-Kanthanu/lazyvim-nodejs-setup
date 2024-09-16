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
