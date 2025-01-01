return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    local wk = require("which-key")
    wk.setup({
      preset = "modern",
      show_help = false,
      show_keys = false,
      win = {
        border = "rounded",
        title = false,
      },
    })
    wk.add({
      {
        "<Leader>ff",
        mode = "n",
        "<cmd>NvimTreeFindFileToggle<cr>",
        desc = "File explorer",
      },
      {
        "<Leader>ca",
        mode = { "n", "v" },
        function()
          vim.lsp.buf.code_action()
        end,
        desc = "Code Actions",
      },
    })
  end,
}
