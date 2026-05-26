local SESSION_NAME = "AI workspace"

local function in_tmux()
  if not vim.env.TMUX then
    vim.notify("Not inside tmux", vim.log.levels.WARN)
    return false
  end
  return true
end

local function configure_and_switch_session(session)
  vim.fn.system(table.concat({
    "tmux set-option -t " .. session .. " mouse on",
    "tmux set-option -t " .. session .. " detach-on-destroy off",
    "tmux switch-client -t " .. session,
  }, " && "))
end

-- Open a tmux window in the shared "AI workspace" session running `cmd`.
-- focus_existing: reuse a window with the same name instead of creating a new one.
local function open_window(name, cwd, cmd, focus_existing)
  if not in_tmux() then
    return
  end

  local session = vim.fn.shellescape(SESSION_NAME)
  local n, c, run = vim.fn.shellescape(name), vim.fn.shellescape(cwd), vim.fn.shellescape(cmd)

  vim.fn.system("tmux has-session -t " .. session .. " 2>/dev/null")
  if vim.v.shell_error ~= 0 then
    vim.fn.system(("tmux new-session -d -s %s -n %s -c %s %s"):format(session, n, c, run))
  elseif focus_existing then
    local existing = vim.fn.system("tmux list-windows -t " .. session .. ' -F "#{window_name}" 2>/dev/null | grep -xF ' .. n)
    if vim.v.shell_error == 0 and existing ~= "" then
      vim.fn.system("tmux select-window -t " .. session .. ":" .. n)
    else
      vim.fn.system(("tmux new-window -t %s -n %s -c %s %s"):format(session, n, c, run))
    end
  else
    vim.fn.system(("tmux new-window -t %s -n %s -c %s %s"):format(session, n, c, run))
  end

  configure_and_switch_session(session)
end

return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "ravitemer/mcphub.nvim",
    "nvim-treesitter/nvim-treesitter",
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
        require("codecompanion").chat({ window_opts = { layout = "buffer", width = 1, height = 1 } })
      end,
      desc = "New Tab AI Chat",
      mode = { "n", "v" },
    },
    {
      "<leader>ax",
      ":'<,'>CodeCompanionChat Add<Return>",
      desc = "Visually selected to AI Chat",
      mode = { "x" },
      silent = true,
    },
    {
      "<leader>aa",
      function()
        local cwd = vim.fn.getcwd()
        open_window("agents[ ]", cwd, "claude agents", true)
      end,
      desc = "New TMUX window with AI agent view",
      mode = { "n", "v" },
      silent = true,
    },
    {
      "<leader>ag",
      function()
        local cwd = vim.fn.getcwd()
        local dir = vim.fn.fnamemodify(cwd, ":t")
        local name = dir .. "[ ]"
        open_window(name, cwd, "claude", false)
      end,
      desc = "New TMUX window with AI agent",
      mode = { "n", "v" },
      silent = true,
    },
    {
      "<leader>aS",
      function()
        local cwd = vim.fn.getcwd()
        vim.fn.jobstart('tmux split-window -v -c "' .. cwd .. '" "claude"', { detach = false })
      end,
      desc = "New TMUX horizontal pane with AI agent",
      mode = { "n", "v" },
      silent = true,
    },
    {
      "<leader>aV",
      function()
        local cwd = vim.fn.getcwd()
        vim.fn.jobstart('tmux split-window -h -c "' .. cwd .. '" "claude"', { detach = false })
      end,
      desc = "New TMUX vertical pane with AI agent",
      mode = { "n", "v" },
      silent = true,
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
        adapter = "claude_code",
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
        adapter = "claude_code",
      },
    },
    memory = {
      opts = {
        chat = {
          enabled = true,
          default_memory = "default",
        },
      },
      default = {
        description = "Collection of common files for all projects",
        files = {
          ".clinerules",
          ".cursorrules",
          ".goosehints",
          ".rules",
          ".windsurfrules",
          ".github/copilot-instructions.md",
          "AGENT.md",
          "AGENTS.md",
          { path = "CLAUDE.md", parser = "claude" },
          { path = "CLAUDE.local.md", parser = "claude" },
          { path = "~/.claude/CLAUDE.md", parser = "claude" },
        },
      },
    },
    adapters = {
      http = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            env = {
              api_key = "cmd:echo ${ANTHROPIC_API_KEY}",
            },
            schema = {
              model = {
                default = "claude-sonnet-4.5",
              },
            },
          })
        end,
      },
      acp = {
        claude_code = function()
          return require("codecompanion.adapters").extend("claude_code", {
            -- Look at (https://codecompanion.olimorris.dev/configuration/adapters#setup-claude-code-via-acp)
            -- env = {
            --   ANTHROPIC_API_KEY = "",
            -- },
          })
        end,
      },
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
            signcolumn = "auto",
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
          make_vars = false, -- TODO: change to true if mcphub.nvim supports codecompanion v19 (see mcphub.nvim#275)
          -- MCP Prompts
          make_slash_commands = true, -- Add MCP prompts as /slash commands
        },
      },
    },
  },
}
