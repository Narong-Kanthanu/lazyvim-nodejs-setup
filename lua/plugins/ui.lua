return {
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
        lualine_c = {},
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
      timeout = 5000,
      background_colour = "#000000",
      render = "wrapped-compact",
    },
  },
  -- tab buffer line
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    keys = {
      { "<Tab>", "<Cmd>BufferLineCycleNext<CR>", desc = "Next tab" },
      { "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev tab" },
    },
    opts = {
      options = {
        mode = "tabs",
        show_buffer_close_icons = false,
        show_close_icon = false,
      },
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
  -- LazyGit integration with Telescope
  {
    "kdheepak/lazygit.nvim",
    keys = {
      {
        "lg",
        ":LazyGit<Return>",
        silent = true,
        noremap = true,
      },
    },
    -- optional for floating window border decoration
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
  -- explorer
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      require("nvim-tree").setup({
        open_on_tab = true,
        update_cwd = true,
        update_focused_file = {
          enable = true,
          update_cwd = true,
        },
        respect_buf_cwd = true,
        on_attach = function(bufnr)
          local api = require("nvim-tree.api")

          local function opts(desc)
            return {
              desc = "nvim-tree: " .. desc,
              buffer = bufnr,
              noremap = true,
              silent = true,
              nowait = true,
            }
          end

          -- default mappings
          api.config.mappings.default_on_attach(bufnr)

          -- custom mappings
          vim.keymap.set("n", "t", api.node.open.tab, opts("Tab"))
        end,
        actions = {
          open_file = {
            quit_on_open = true,
          },
        },
        sort = {
          sorter = "case_sensitive",
        },
        view = {
          width = 35,
          relativenumber = false,
        },
        renderer = {
          group_empty = true,
          root_folder_modifier = ":t",
          icons = {
            padding = "  ",
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
            },
          },
          indent_markers = {
            enable = true,
          },
        },
        filters = {
          dotfiles = true,
          custom = {
            "node_modules/.*",
          },
        },
        log = {
          enable = true,
          truncate = true,
          types = {
            diagnostics = true,
            git = true,
            profile = true,
            watcher = true,
          },
        },
        git = {
          enable = true,
        },
      })

      if vim.fn.argc(-1) == 0 then
        vim.cmd("NvimTreeFocus")
      end
    end,
  },
  -- blankline
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
  -- rainbow delimiters
  {
    "HiPhish/rainbow-delimiters.nvim",
    config = function()
      local scope_highlight = {
        "RainbowRed",
        "RainbowYellow",
        "RainbowBlue",
        "RainbowOrange",
        "RainbowGreen",
        "RainbowViolet",
        "RainbowCyan",
      }
      local indent_highlight = {
        "DimGray",
      }
      local hooks = require("ibl.hooks")
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
        vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
        vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
        vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
        vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
        vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
        vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
        vim.api.nvim_set_hl(0, "DimGray", { fg = "#333333" })
      end)
      local rainbow_delimiters = require("rainbow-delimiters")

      vim.g.rainbow_delimiters = {
        -- define strategy for improve editor performance
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
          vim = rainbow_delimiters.strategy["global"],
          lua = rainbow_delimiters.strategy["global"],
          gitignore = rainbow_delimiters.strategy["global"],
          graphql = rainbow_delimiters.strategy["global"],
          typescript = function(bufnr)
            local line_count = vim.api.nvim_buf_line_count(bufnr)
            if line_count >= 0 and line_count <= 1000 then
              return rainbow_delimiters.strategy["global"]
            end
            return rainbow_delimiters.strategy["local"]
          end,
          javascript = function(bufnr)
            local line_count = vim.api.nvim_buf_line_count(bufnr)
            if line_count >= 0 and line_count <= 1000 then
              return rainbow_delimiters.strategy["global"]
            end
            return rainbow_delimiters.strategy["local"]
          end,
          json = function(bufnr)
            local line_count = vim.api.nvim_buf_line_count(bufnr)
            if line_count >= 0 and line_count <= 100000 then
              return rainbow_delimiters.strategy["global"]
            end
            return rainbow_delimiters.strategy["local"]
          end,
        },
        -- define query defines what to language match
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
          javascript = "rainbow-parens",
          typescript = "rainbow-parens",
        },
        highlight = scope_highlight,
      }
      require("ibl").setup({
        scope = {
          enabled = true,
          show_start = true,
          show_end = true,
          injected_languages = true,
          highlight = scope_highlight,
        },
        indent = {
          smart_indent_cap = true,
          repeat_linebreak = true,
          priority = 1,
          highlight = indent_highlight,
        },
      })

      hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)
    end,
  },
}
