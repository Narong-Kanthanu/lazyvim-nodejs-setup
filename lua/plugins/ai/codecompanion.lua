return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    { "nvim-lua/plenary.nvim", branch = "master" },
    { "ravitemer/mcphub.nvim" },
  },
  keys = {
    { "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
    {
      "<leader>av",
      function()
        return require("codecompanion").toggle({ window_opts = { position = "vertical", width = 0.5, height = 1 } })
      end,
      desc = "Toggle Vertical AI Chat",
      mode = { "n", "v" },
    },
    {
      "<leader>as",
      function()
        return require("codecompanion").toggle({ window_opts = { layout = "horizontal", width = 1, height = 0.5 } })
      end,
      desc = "Toggle Horizontal AI Chat",
      mode = { "n", "v" },
    },
    {
      "<leader>at",
      function()
        vim.cmd("tabnew")
        vim.schedule(function()
          require("codecompanion").chat({ window_opts = { layout = "buffer", width = 1, height = 1 } })
        end)
      end,
      desc = "New Tab AI Chat",
      mode = { "n", "v" },
    },
    {
      "<leader>ax",
      ":'<,'>CodeCompanionChat Add<Return>",
      desc = "Visually selected chat to AI",
      mode = { "x" },
    },
  },
  opts = {
    strategies = {
      chat = {
        adapter = {
          name = "copilot",
          model = "claude-sonnet-4.5",
        },
        keymaps = {
          send = {
            modes = { n = "<C-s>", i = "<C-s>" },
            opts = {},
          },
          close = {
            modes = { n = "<C-c>", i = "<C-c>" },
            opts = {},
          },
          clear = {
            modes = { n = "<C-l>", i = "<C-l>" },
            opts = {},
          },
        },
        tools = {
          ["cmd_runner"] = {
            opts = {
              requires_approval = true,
            },
          },
        },
      },
      inline = {
        adapter = "anthropic",
        model = "claude-sonnet-4-20250514",
        keymaps = {
          accept_change = {
            modes = { n = "aa" },
            description = "Accept the suggested change",
          },
          reject_change = {
            modes = { n = "ar" },
            opts = { nowait = true },
            description = "Reject the suggested change",
          },
        },
      },
      cmd = {
        adapter = "copilot",
        model = "gpt-5-codex",
      },
    },
    adapters = {
      http = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            env = {
              api_key = "", -- set yout API key
            },
          })
        end,
      },
      acp = {}, -- set your Agent Client Protocol
    },
    display = {
      chat = {
        intro_message = "",
        separator = "─",
        auto_scroll = true,
        show_header_separator = true,
        show_context = true, -- Show context (from slash commands and variables) in the chat buffer?
        fold_context = false, -- Fold context in the chat buffer?
        show_reasoning = true, -- Show reasoning content in the chat buffer?
        fold_reasoning = true, -- Fold the reasoning content in the chat buffer?
        show_settings = false, -- Show LLM settings at the top of the chat buffer?
        show_tools_processing = true, -- Show the loading message when tools are being executed?
        show_token_count = false, -- Show the token count for each response?
        start_in_insert_mode = false, -- Open the chat buffer in insert mode?
        token_count = function(tokens, _)
          return tokens .. " tokens"
        end,
        icons = {
          buffer_pin = " ",
          buffer_watch = "󰂥 ",
          chat_context = " ",
          chat_fold = " ",
          tool_pending = " ",
          tool_in_progress = " ",
          tool_failure = " ",
          tool_success = " ",
        },
        window = {
          layout = "vertical",
          position = nil,
          border = "rounded",
          width = 0.50,
          relative = "editor",
          full_height = true,
          sticky = false,
          opts = {
            number = false,
            relativenumber = false,
            breakindent = true,
            cursorcolumn = false,
            cursorline = false,
            foldcolumn = "0",
            linebreak = true,
            list = false,
            numberwidth = 1,
            signcolumn = "yes:1",
            spell = false,
            wrap = true,
          },
        },
        child_windows = {
          width = function()
            return vim.o.columns - 5
          end,
          height = function()
            return vim.o.lines - 2
          end,
          row = "center",
          col = "center",
          relative = "editor",
          opts = {
            wrap = false,
            number = false,
            relativenumber = false,
          },
        },
        diff_window = {
          width = function()
            return math.min(120, vim.o.columns - 10)
          end,
          height = function()
            return vim.o.lines - 4
          end,
          opts = {
            number = true,
          },
        },
      },
      action_palette = {
        width = 95,
        height = 10,
        prompt = "Prompt ",
        provider = "default",
        opts = {
          show_default_actions = true, -- Show the default actions in the action palette?
          show_default_prompt_library = true, -- Show the default prompt library in the action palette?
          title = "CodeCompanion actions", -- The title of the action palette
        },
      },
    },
    extensions = {
      mcphub = {
        callback = "mcphub.extensions.codecompanion",
        opts = {
          -- MCP Tools
          make_tools = true, -- Make individual tools (@server__tool) and server groups (@server) from MCP servers
          show_server_tools_in_chat = true, -- Show individual tools in chat completion (when make_tools=true)
          add_mcp_prefix_to_tool_names = false, -- Add mcp__ prefix (e.g `@mcp__github`, `@mcp__neovim__list_issues`)
          show_result_in_chat = true, -- Show tool results directly in chat buffer
          format_tool = nil, -- function(tool_name:string, tool: CodeCompanion.Agent.Tool) : string Function to format tool names to show in the chat buffer
          -- MCP Resources
          make_vars = true, -- Convert MCP resources to #variables for prompts
          -- MCP Prompts
          make_slash_commands = true, -- Add MCP prompts as /slash commands
        },
      },
    },
  },
}
