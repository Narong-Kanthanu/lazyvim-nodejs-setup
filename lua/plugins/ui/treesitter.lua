return {
  {
    "nvim-treesitter/nvim-treesitter",
    tag = "v0.9.2",
    opts = {
      ensure_installed = {
        "javascript",
        "typescript",
        "gitignore",
        "graphql",
        "http",
        "json",
        "vim",
        "lua",
        "xml",
        "markdown",
      },
      query_linter = {
        enable = true,
        use_virtual_text = true,
        lint_events = { "BufWrite", "CursorHold" },
      },
    },
  },
}
