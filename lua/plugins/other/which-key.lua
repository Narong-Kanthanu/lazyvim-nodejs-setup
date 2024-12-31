return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {},
  keys = {
    {
      "<Leader>ff",
      mode = "n",
      function()
        vim.cmd(":NvimTreeFindFileToggle<Return>")
      end,
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
  },
}
