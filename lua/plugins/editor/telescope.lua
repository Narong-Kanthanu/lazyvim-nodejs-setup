return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  version = false,
  priority = 1000,
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
    "nvim-telescope/telescope-file-browser.nvim",
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
    "debugloop/telescope-undo.nvim",
  },
  keys = {
    {
      ";f", -- find in folder
      function()
        require("telescope.builtin").find_files()
      end,
      desc = "Lists files in your current working directory, respects .gitignore",
    },
    {
      ";r", -- search file from string
      function()
        require("telescope.builtin").live_grep()
      end,
      desc = "Search for a string in your current working directory and get results live as you type, respects .gitignore",
    },
    {
      ";d", -- pick a directory, then live grep in it
      function()
        local builtin = require("telescope.builtin")
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        local entry_display = require("telescope.pickers.entry_display")
        local root = vim.fn.getcwd() -- stable base: don't recompute from the opened file's buffer

        local displayer = entry_display.create({
          separator = " ",
          items = { { width = 2 }, { remaining = true } },
        })

        builtin.find_files({
          prompt_title = "Select Directory to Grep",
          cwd = root,
          hidden = false, -- don't inherit hidden=true from opts.pickers.find_files (Telescope would append --hidden)
          find_command = { "fd", "--type", "d", "--strip-cwd-prefix" },
          entry_maker = function(line)
            return {
              value = line,
              ordinal = line,
              display = function()
                return displayer({ { "", "Directory" }, line })
              end,
            }
          end,
          attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
              local entry = action_state.get_selected_entry()
              actions.close(prompt_bufnr)
              if not entry then
                return
              end

              local dir = entry.value or entry[1]
              builtin.live_grep({
                search_dirs = { vim.fs.joinpath(root, dir) },
                prompt_title = string.format("Live Grep in [%s]", dir),
              })
            end)
            return true
          end,
        })
      end,
      desc = "Pick a directory, then live grep in it, respects .gitignore",
    },
    {
      ";m",
      function()
        require("telescope.builtin").marks()
      end,
      desc = "Lists marks points in the current buffer",
    },
    {
      "\\\\", -- list open buffer files
      function()
        require("telescope.builtin").buffers()
      end,
      desc = "Lists open buffers",
    },
    {
      ";;", -- resume previous command
      function()
        require("telescope.builtin").resume()
      end,
      desc = "Resume the previous telescope picker",
    },
    {
      ";e",
      function()
        require("telescope.builtin").diagnostics({
          bufnr = 0,
        })
      end,
      desc = "Lists Diagnostics for all open buffers or a specific buffer at current buffer",
    },
    {
      ";s",
      function()
        require("telescope.builtin").treesitter()
      end,
      desc = "Lists Function names, variables, from Treesitter",
    },
    {
      "sf",
      function()
        local telescope = require("telescope")
        telescope.extensions.file_browser.file_browser()
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
          ["<C-v>"] = actions.select_vertical,
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
        find_command = { "fd", "--type", "f", "--strip-cwd-prefix" },
        hidden = true,
        theme = "dropdown",
        previewer = false,
        layout_config = { height = 40 },
      },
      buffers = {
        only_cwd = true,
        show_all_buffers = false,
        sort_mru = true,
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
        layout_config = { height = 40 },
      },
      live_grep = {
        no_ignore = false,
        hidden = true,
        previewer = true,
        show_line = false, -- hide match text in results; still shown in preview
        layout_config = {
          height = 40,
          preview_width = 0.7, -- narrower Results, wider Grep Preview
        },
        max_results = 20,
      },
      marks = {
        initial_mode = "normal",
        mark_type = "all",
        no_ignore = false,
        hidden = true,
        previewer = true,
        mappings = {
          ["i"] = {
            ["<C-d>"] = actions.delete_mark,
          },
          ["v"] = {},
          ["n"] = {
            ["d"] = actions.delete_mark,
          },
        },
        layout_config = { height = 40 },
      },
      treesitter = {
        initial_mode = "normal",
        previewer = true,
        layout_config = {
          height = 40,
          preview_width = 0.65,
        },
      },
    }
    opts.extensions = {
      file_browser = {
        theme = "dropdown",
        hijack_netrw = true,
        path = "%:p:h",
        cwd = vim.fn.expand("%:p:h"),
        respect_gitignore = false,
        hidden = true,
        grouped = true,
        previewer = false,
        initial_mode = "normal",
        layout_config = { height = 40 },
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
        layout_config = {
          height = 40,
          preview_width = 0.65,
        },
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
}
