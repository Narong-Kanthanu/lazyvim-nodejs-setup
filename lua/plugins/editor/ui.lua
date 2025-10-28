return {
  -- dashboard
  {
    "nvimdev/dashboard-nvim",
    enabled = false,
  },
  -- status line
  {
    "nvim-lualine/lualine.nvim",
    enabled = true,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "everforest",
        icons_enabled = true,
        globalstatus = true,
        always_divide_middle = true,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = {
          {
            "diagnostics",
            sources = { "nvim_diagnostic", "coc" },
            sections = { "error", "warn", "info", "hint" },
            diagnostics_color = {
              error = "DiagnosticError",
              warn = "DiagnosticWarn",
              info = "DiagnosticInfo",
              hint = "DiagnosticHint",
            },
            colored = false,
            update_in_insert = false,
            always_visible = false,
          },
        },
        lualine_x = {
          { "filetype", colored = true, icon_only = false },
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
    config = function(_, opts)
      require("lualine").setup(opts)
    end,
  },
  -- messages, cmdline and the popupmenu
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      table.insert(opts.routes, {
        filter = {
          event = "notify",
          find = "No information available",
        },
        opts = { skip = true },
      })
      local focused = true
      vim.api.nvim_create_autocmd("FocusGained", {
        callback = function()
          focused = true
        end,
      })
      vim.api.nvim_create_autocmd("FocusLost", {
        callback = function()
          focused = false
        end,
      })
      table.insert(opts.routes, 1, {
        filter = {
          cond = function()
            return not focused
          end,
        },
        view = "notify_send",
        opts = { stop = false },
      })
      opts.commands = {
        all = {
          -- options for the message history that you get with `:Noice`
          view = "split",
          opts = { enter = true, format = "details" },
          filter = {},
        },
      }
      opts.presets.lsp_doc_border = true
    end,
  },
  -- notify
  {
    "rcarriga/nvim-notify",
    opts = {
      timeout = 2500,
      background_colour = "#2A2A2A",
      render = "wrapped-compact",
    },
  },
  -- tab buffer line
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = function()
      local buffer_keys = {
        { "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
        { "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Previous tab" },
      }
      for i = 1, 9 do
        table.insert(buffer_keys, {
          i .. "<Tab>",
          "<Cmd>BufferLineGoToBuffer " .. i .. "<CR>",
          desc = "Go to buffer " .. i,
        })
      end
      return buffer_keys
    end,
    opts = {
      options = {
        mode = "tabs",
        name_formatter = function(buf)
          if buf.name:match("CodeCompanion") then
            return "AI Chat"
          else
            return buf.name
          end
        end,
        get_element_icon = function(element)
          local icon, hl = require("nvim-web-devicons").get_icon_by_filetype(element.filetype, { default = false })
          if element.filetype == "codecompanion" then
            icon = " "
          end
          return icon, hl
        end,
        show_tab_indicators = false,
        show_close_icon = false,
        show_buffer_icons = true,
        show_buffer_close_icons = false,
        always_show_bufferline = false,
        color_icons = true,
        themable = false,
        separator_style = { "", "" },
        numbers = "none",
        indicator = {
          icon = " ",
          style = "underline",
        },
      },
      highlights = function()
        local updated = {}
        local option_keys = {
          "fill",
          "background",
          "tab",
          "tab_selected",
          "tab_separator",
          "tab_separator_selected",
          "tab_close",
          "close_button",
          "close_button_visible",
          "close_button_selected",
          "buffer_visible",
          "buffer_selected",
          "numbers",
          "numbers_visible",
          "numbers_selected",
          "diagnostic",
          "diagnostic_visible",
          "diagnostic_selected",
          "hint",
          "hint_visible",
          "hint_selected",
          "hint_diagnostic",
          "hint_diagnostic_visible",
          "hint_diagnostic_selected",
          "info",
          "info_visible",
          "info_selected",
          "info_diagnostic",
          "info_diagnostic_visible",
          "info_diagnostic_selected",
          "warning",
          "warning_visible",
          "warning_selected",
          "warning_diagnostic",
          "warning_diagnostic_visible",
          "warning_diagnostic_selected",
          "error",
          "error_visible",
          "error_selected",
          "error_diagnostic",
          "error_diagnostic_visible",
          "error_diagnostic_selected",
          "modified",
          "modified_visible",
          "modified_selected",
          "duplicate_selected",
          "duplicate_visible",
          "duplicate",
          "separator_selected",
          "separator_visible",
          "separator",
          "indicator_visible",
          "indicator_selected",
          "pick_selected",
          "pick_visible",
          "pick",
          "offset_separator",
          "trunc_marker",
        }
        for _, key in ipairs(option_keys) do
          if key == "indicator_selected" or key == "buffer_selected" then
            updated[key] = { fg = "#f2f2f2", bg = "#2a2a2a" }
          else
            updated[key] = { bg = "#2a2a2a" }
          end
        end
        return updated
      end,
    },
  },
  -- show filename with new window on the top
  {
    "b0o/incline.nvim",
    dependencies = {},
    event = "BufReadPre",
    priority = 1200,
    config = function()
      local helpers = require("incline.helpers")
      require("incline").setup({
        window = {
          padding = 0,
          margin = { horizontal = 0 },
        },
        render = function(props)
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          local ft_icon, ft_color = require("nvim-web-devicons").get_icon_color(filename)
          local modified = vim.bo[props.buf].modified
          local buffer = {
            ft_icon and { " ", ft_icon, " ", guibg = ft_color, guifg = helpers.contrast_color(ft_color) } or "",
            " ",
            { filename, gui = modified and "bold,italic" or "bold" },
            " ",
            guibg = "#363944",
          }
          return buffer
        end,
      })
    end,
  },
}
