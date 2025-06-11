return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      local nvim_tree = require("nvim-tree")
      local api = require("nvim-tree.api")

      -- Set custom keymaps
      local function on_attach(bufnr)
        local function opts(desc)
          return {
            desc = "nvim-tree: " .. desc,
            buffer = bufnr,
            noremap = true,
            silent = true,
            nowait = true,
          }
        end

        api.config.mappings.default_on_attach(bufnr)
        vim.keymap.set("n", "t", api.node.open.tab, opts("Open in new tab"))
      end

      nvim_tree.setup({
        on_attach = on_attach,
        sort = {
          sorter = "case_sensitive",
        },
        view = {
          width = 35,
          relativenumber = false,
        },
        renderer = {
          group_empty = true,
          root_folder_label = false,
          indent_markers = {
            enable = true,
          },
          special_files = { "README.md", "readme.md" },
          icons = {
            padding = "  ",
            webdev_colors = false,
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
              modified = true,
              diagnostics = true,
              bookmarks = true,
            },
            web_devicons = {
              file = { enable = true, color = true },
              folder = { enable = true, color = true },
            },
            glyphs = {
              default = "",
              symlink = "",
              bookmark = "󰆤",
              modified = "●",
              folder = {
                arrow_closed = "",
                arrow_open = "",
                default = "",
                open = "",
                empty = "",
                empty_open = "",
                symlink = "",
                symlink_open = "",
              },
              git = {
                unstaged = "✗",
                staged = "✓",
                unmerged = "",
                renamed = "➜",
                untracked = "★",
                deleted = "",
                ignored = "◌",
              },
            },
          },
        },
        update_focused_file = {
          enable = true,
          update_cwd = true,
        },
        respect_buf_cwd = true,
        update_cwd = true,
        actions = {
          open_file = {
            quit_on_open = true,
          },
        },
        filters = {
          dotfiles = true,
          custom = { "node_modules/.*" },
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

      -- Auto open on startup if no files were passed
      if vim.fn.argc(-1) == 0 then
        vim.cmd("NvimTreeFocus")
      end

      -- Custom highlight colors
      vim.cmd([[
        highlight NvimTreeStatusLine guibg=#3c474e
        highlight NvimTreeWindowPicker guibg=#3c474e
      ]])
    end,
  },
}
