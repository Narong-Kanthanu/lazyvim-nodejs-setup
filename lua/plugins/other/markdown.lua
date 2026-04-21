local workspaces = {}
local personal_vault_path = os.getenv("PERSONAL_VAULT_PATH")
local work_vault_path = os.getenv("WORK_VAULT_PATH")
if personal_vault_path and personal_vault_path ~= "" then
  table.insert(workspaces, { name = "personal", path = personal_vault_path })
end
if work_vault_path and work_vault_path ~= "" then
  table.insert(workspaces, { name = "work", path = work_vault_path })
end
if #workspaces == 0 then
  table.insert(workspaces, { name = "default", path = vim.fn.getcwd() })
end

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
      workspaces = workspaces,
    },
  },
  {
    "Narong-Kanthanu/llm-kiwi.nvim",
    cmd = { "LlmKiwiOpen", "LlmKiwiClose", "LlmKiwiList" },
    config = function()
      require("llm-kiwi").setup({
        port = 18765,
        open_browser = true,
        nvim_server = true,
        workspaces = workspaces,
      })
    end,
    keys = {
      { "<leader>k", "", desc = "LLM Kiwi", mode = { "n" } },
      {
        "<leader>kw",
        function()
          require("llm-kiwi").open()
        end,
        mode = { "n" },
        desc = "Open knowledge network graph",
      },
      {
        "<leader>kq",
        function()
          require("llm-kiwi").close()
        end,
        mode = { "n" },
        desc = "Stop running graph server",
      },
    },
  },
}
