return {
  -- LSP management servers tool
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "luacheck",
        "shellcheck",
        "shfmt",
        "typescript-language-server",
        "bash-language-server",
      })
    end,
  },
}
