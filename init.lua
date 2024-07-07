-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- inlay hint toggles
if vim.lsp.inlay_hint then
  vim.keymap.set("n", "<Leader>uh", function()
    vim.lsp.inlay_hint(0, nil)
  end, { desc = "Toggle Inlay Hints" })
end
