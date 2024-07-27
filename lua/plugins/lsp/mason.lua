return {
  -- LSP management servers tool
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "shellcheck",
        "shfmt",
        "vtsls", -- vscode tsserver.
        "bash-language-server",
      })
    end,
  },
}
