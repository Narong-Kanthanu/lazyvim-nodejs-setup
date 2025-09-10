return {
  -- copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = not vim.g.ai_cmp,
          auto_trigger = false,
          hide_during_completion = true,
        },
        panel = {
          enabled = false,
        },
        filetypes = {
          ["*"] = true, -- default enabled all file types
        },
      })
    end,
  },
  -- copilot chat
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    build = "make tiktoken",
    cmd = "CopilotChat",
    opts = function()
      local user = vim.env.USER or "User"
      user = user:sub(1, 1):upper() .. user:sub(2)
      return {
        auto_insert_mode = true,
        show_folds = true,
        insert_at_end = true,
        stop_on_function_failure = true,
        separator = "━━",
        window = {
          width = 0.5,
        },
        headers = {
          user = "  " .. user .. " ",
          assistant = "  Copilot ",
          tool = "🛠Tool",
        },
      }
    end,
    keys = {
      { "<c-s>", "<CR>", ft = "copilot-chat", desc = "Submit Prompt", remap = true },
      { "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
      {
        "<leader>am",
        function()
          vim.cmd("CopilotChatModels")
        end,
        desc = "Select AI models",
        mode = { "n", "v" },
      },
      {
        "<leader>av",
        function()
          return require("CopilotChat").toggle({
            window = {
              layout = "vertical",
            },
          })
        end,
        desc = "Toggle vertical (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "<leader>as",
        function()
          return require("CopilotChat").toggle({
            window = {
              layout = "horizontal",
            },
          })
        end,
        desc = "Toggle horizontal (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "<leader>at",
        function()
          vim.cmd("tabnew")
          require("CopilotChat").toggle({
            window = { layout = "replace" },
          })
        end,
        desc = "Toggle new tab (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "<leader>ax",
        function()
          return require("CopilotChat").reset()
        end,
        desc = "Clear (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "<leader>aq",
        function()
          vim.ui.input({
            prompt = "Quick Chat: ",
          }, function(input)
            if input ~= "" then
              require("CopilotChat").ask(input)
            end
          end)
        end,
        desc = "Quick Chat (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "<leader>ap",
        function()
          require("CopilotChat").select_prompt()
        end,
        desc = "Prompt Actions (CopilotChat)",
        mode = { "n", "v" },
      },
    },
    config = function(_, opts)
      local chat = require("CopilotChat")

      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "copilot-chat",
        callback = function()
          vim.opt_local.relativenumber = false
          vim.opt_local.number = false
        end,
      })

      chat.setup(opts)
    end,
  },
}
