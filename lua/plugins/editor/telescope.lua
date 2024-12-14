return {
  {
    "telescope.nvim",
    priority = 1000,
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
      "nvim-telescope/telescope-file-browser.nvim",
      "nvim-tree/nvim-web-devicons",
      "debugloop/telescope-undo.nvim",
    },
    keys = {
      {
        ";f", -- find in folder
        function()
          local builtin = require("telescope.builtin")
          builtin.find_files()
        end,
        desc = "Lists files in your current working directory, respects .gitignore",
      },
      {
        ";r", -- search file from string
        function()
          local builtin = require("telescope.builtin")
          builtin.live_grep()
        end,
        desc = "Search for a string in your current working directory and get results live as you type, respects .gitignore",
      },
      {
        "\\\\", -- list open buffer files
        function()
          local builtin = require("telescope.builtin")
          builtin.buffers()
        end,
        desc = "Lists open buffers",
      },
      {
        ";;", -- resume previous command
        function()
          local builtin = require("telescope.builtin")
          builtin.resume()
        end,
        desc = "Resume the previous telescope picker",
      },
      {
        ";e",
        function()
          local builtin = require("telescope.builtin")
          builtin.diagnostics({
            bufnr = 0,
          })
        end,
        desc = "Lists Diagnostics for all open buffers or a specific buffer at current buffer",
      },
      {
        ";s",
        function()
          local builtin = require("telescope.builtin")
          builtin.treesitter()
        end,
        desc = "Lists Function names, variables, from Treesitter",
      },
      {
        "sf",
        function()
          local telescope = require("telescope")

          local function telescope_buffer_dir()
            return vim.fn.expand("%:p:h")
          end

          telescope.extensions.file_browser.file_browser({
            path = "%:p:h",
            cwd = telescope_buffer_dir(),
            respect_gitignore = false,
            hidden = true,
            grouped = true,
            previewer = false,
            initial_mode = "normal",
            layout_config = { height = 40 },
          })
        end,
        desc = "Open File Browser with the path of the current buffer",
      },
      {
        ";u",
        function()
          local telescope = require("telescope")
          telescope.extensions.undo.undo()
        end,
        desc = "Undo history",
      },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local fb_actions = require("telescope").extensions.file_browser.actions
      local undo_actions = require("telescope-undo.actions")

      opts.defaults = vim.tbl_deep_extend("force", opts.defaults, {
        wrap_results = true,
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
        mappings = {
          ["i"] = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-t>"] = actions.select_tab,
            ["<C-v"] = actions.select_vertical,
            ["<C-s>"] = actions.select_horizontal,
            ["<CR>"] = actions.select_default,
          },
          ["v"] = {},
          ["n"] = {
            ["j"] = actions.move_selection_next,
            ["k"] = actions.move_selection_previous,
            ["t"] = actions.select_tab,
            ["sv"] = actions.select_vertical,
            ["ss"] = actions.select_horizontal,
            ["<CR>"] = actions.select_default,
          },
        },
      })
      opts.pickers = {
        find_files = {
          no_ignore = false,
          hidden = true,
          theme = "dropdown",
          previewer = false,
          layout_config = {
            height = 40,
          },
        },
        buffers = {
          only_cwd = true,
          show_all_buffers = false,
          previewer = false,
          mappings = {
            ["i"] = {
              ["<C-d>"] = actions.delete_buffer,
            },
            ["v"] = {},
            ["n"] = {
              ["d"] = actions.delete_buffer,
            },
          },
          layout_config = {
            height = 40,
            width = 0.4,
          },
        },
        diagnostics = {
          initial_mode = "normal",
          previewer = false,
          layout_config = {
            height = 40,
          },
        },
        live_grep = {
          no_ignore = false,
          hidden = true,
          previewer = true,
          layout_config = { height = 40 },
        },
      }
      opts.extensions = {
        file_browser = {
          theme = "dropdown",
          -- disables netrw and use telescope-file-browser in its place
          hijack_netrw = true,
          mappings = {
            ["i"] = {},
            ["v"] = {},
            ["n"] = {
              ["N"] = fb_actions.create,
              ["h"] = fb_actions.goto_parent_dir,
              ["<C-k>"] = function(prompt_bufnr)
                for _ = 1, 10 do
                  actions.move_selection_previous(prompt_bufnr)
                end
              end,
              ["<C-j>"] = function(prompt_bufnr)
                for _ = 1, 10 do
                  actions.move_selection_next(prompt_bufnr)
                end
              end,
            },
          },
        },
        undo = {
          initial_mode = "normal",
          no_ignore = false,
          hidden = true,
          previewer = true,
          side_by_side = true,
          saved_only = false,
          layout_config = { height = 40 },
          mappings = {
            ["i"] = {
              ["<cr>"] = undo_actions.restore,
              ["<S-cr>"] = undo_actions.yank_deletions,
              ["<C-cr>"] = function(bufnr)
                return undo_actions.yank_larger(bufnr)
              end,
            },
            ["v"] = {},
            ["n"] = {
              ["u"] = undo_actions.restore,
              ["Y"] = undo_actions.yank_deletions,
              ["y"] = function(bufnr)
                return undo_actions.yank_larger(bufnr)
              end,
            },
          },
        },
      }
      telescope.setup(opts)
      require("telescope").load_extension("fzf")
      require("telescope").load_extension("file_browser")
      require("telescope").load_extension("undo")
    end,
  },
}
