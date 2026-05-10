-- bootstrap lazy.nvim, LazyVim and your plugins
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

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

-- Set fg of hl for window separator
function SetHlForWinSeparator()
  vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#b7bdf8" })
end

vim.schedule(function()
  SetHlForFloatingWindow()
  SetHlForWinSeparator()
end)
