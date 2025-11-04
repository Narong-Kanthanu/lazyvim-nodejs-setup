return {
  {
    "toppair/peek.nvim",
    event = { "VeryLazy" },
    build = "deno task --quiet build:fast",
    config = function()
      require("peek").setup({
        auto_load = true,
        close_on_bdelete = true,
        syntax = true,
        theme = "dark",
        update_on_change = true,
        app = "webview", -- 'webview', 'browser', string or a table of strings
        filetype = { "markdown" },
        throttle_at = 200000,
        throttle_time = "auto",
      })
    end,
    keys = {
      { "<leader>m", "", desc = "Markdown", mode = { "n" } },
      {
        "<Leader>md",
        function()
          require("peek").open()
        end,
        desc = "󰈔 Preview markdown",
        mode = { "n" },
      },
      {
        "<Leader>mq",
        function()
          require("peek").close()
        end,
        desc = "󰈔 Stop preview markdown",
        mode = { "n" },
      },
    },
  },
}
