return {
  {
    "toppair/peek.nvim",
    ft = "markdown",
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
        "<leader>md",
        function()
          require("peek").open()
        end,
        desc = "󰈔 Preview markdown",
        mode = { "n" },
      },
      {
        "<leader>mq",
        function()
          require("peek").close()
        end,
        desc = "󰈔 Stop preview markdown",
        mode = { "n" },
      },
    },
  },
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*", -- use latest release, remove to use latest commit
    opts = {
      legacy_commands = false, -- this will be removed in the next major release
      sync = {
        enabled = false,
      },
      workspaces = {
        {
          name = "personal",
          path = os.getenv("PERSONAL_VAULT_PATH"), -- set this env variable in your shell config to point to your vault
        },
        {
          name = "work",
          path = os.getenv("WORK_VAULT_PATH"), -- set this env variable in your shell config to point to your vault
        },
      },
    },
    keys = {
      {
        "<leader>mo",
        function()
          local ws = Obsidian.workspace
          local script = vim.fn.stdpath("config") .. "/lua/scripts/vault-graph.py"
          vim.fn.jobstart({
            "python3",
            script,
            "--all",
            "--active",
            ws.name,
          }, { detach = true })
        end,
        mode = { "n" },
        desc = "Open Obsidian graph",
      },
    },
  },
}
