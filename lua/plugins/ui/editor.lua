return {
  -- Hihglight colors
  {
    "echasnovski/mini.hipatterns",
    event = "BufReadPre",
    opts = {},
  },
  -- Telescope
  {
    "telescope.nvim",
    priority = 1000,
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
      "nvim-telescope/telescope-file-browser.nvim",
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
          builtin.diagnostics()
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
    },
    config = function(_, opts)
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local fb_actions = require("telescope").extensions.file_browser.actions

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
          layout_config = { height = 40 },
        },
        buffers = {
          only_cwd = true,
          show_all_buffers = false,
          mappings = {
            ["i"] = {
              ["<C-d>"] = actions.delete_buffer,
            },
            ["v"] = {},
            ["n"] = {
              ["d"] = actions.delete_buffer,
            },
          },
        },
        diagnostics = {
          tbufnr = 0,
          heme = "ivy",
          initial_mode = "normal",
          layout_config = {
            preview_cutoff = 9999,
          },
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
      }
      telescope.setup(opts)
      require("telescope").load_extension("fzf")
      require("telescope").load_extension("file_browser")
    end,
  },
  -- find and list all TODO and other comment.
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    event = { "LazyFile" },
    opts = {},
    keys = {
      {
        "]t",
        function()
          require("todo-comments").jump_next()
        end,
        desc = "Next Todo Comment",
      },
      {
        "[t",
        function()
          require("todo-comments").jump_prev()
        end,
        desc = "Previous Todo Comment",
      },
      { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo (Trouble)" },
      {
        "<leader>xT",
        "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>",
        desc = "Todo/Fix/Fixme (Trouble)",
      },
      { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo" },
      { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme" },
    },
  },
  -- bookmarks
  {
    "LintaoAmons/bookmarks.nvim",
    dependencies = {
      { "nvim-telescope/telescope.nvim" },
      { "stevearc/dressing.nvim" },
      config = function()
        require("bookmarks").setup({
          json_db_path = vim.fs.normalize(vim.fn.stdpath("config") .. "/bookmarks.db.json"),
          signs = {
            mark = { icon = "", color = "#98C379" },
          },
          hooks = {
            {
              callback = function(bookmark, projects)
                local project_path
                for _, p in ipairs(projects) do
                  if p.name == bookmark.location.project_name then
                    project_path = p.path
                  end
                  if project_path then
                    vim.cmd("cd " .. project_path)
                  end
                end
              end,
            },
          },
        })
      end,
    },
  },
}
