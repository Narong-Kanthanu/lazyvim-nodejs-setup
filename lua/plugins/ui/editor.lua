return {
  -- Hihglight colors
  {
    "echasnovski/mini.hipatterns",
    event = "BufReadPre",
    opts = {},
  },
  -- find and list all TODO and other comment.
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    event = { "LazyFile" },
    opts = {
      signs = true,
      sign_priority = 8,
      keywords = {
        FIX = {
          icon = " ",
          color = "error",
          alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
          -- signs = false, -- configure signs for some keywords individually
        },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      },
      gui_style = {
        fg = "NONE",
        bg = "BOLD",
      },
      merge_keywords = true,
      highlight = {
        multiline = true,
        multiline_pattern = "^.",
        multiline_context = 10,
        before = "",
        keyword = "wide",
        after = "fg",
        pattern = [[.*<(KEYWORDS)\s*:]],
        comments_only = true,
        max_line_len = 400,
        exclude = {},
      },
      colors = {
        error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
        warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
        info = { "DiagnosticInfo", "#2563EB" },
        hint = { "DiagnosticHint", "#10B981" },
        default = { "Identifier", "#7C3AED" },
        test = { "Identifier", "#FF00FF" },
      },
      search = {
        command = "rg",
        args = {
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
        },
        pattern = [[\b(KEYWORDS):]],
      },
    },
    keys = {
      {
        "tk",
        function()
          require("todo-comments").jump_next()
        end,
        desc = "Next Todo Comment",
      },
      {
        "tj",
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
