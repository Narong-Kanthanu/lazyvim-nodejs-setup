return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
  build = "cd app && npm install",
  ft = { "markdown" },
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
    vim.g.mkdp_preview_options = {
      mkit = {},
      katex = {},
      maid = {},
      disable_sync_scroll = 0,
      sync_scroll_type = "middle",
      hide_yaml_meta = 1,
      sequence_diagrams = {},
      flowchart_diagrams = {},
      content_editable = false,
      disable_filename = 0,
      toc = {},
    }
    function OpenMarkdownPreview(url)
      local safari_running = vim.fn.system("pgrep -x Safari")
      if safari_running ~= "" then
        vim.fn.jobstart({ "open", "-a", "Safari", url })
      else
        vim.fn.jobstart({ "open", "-a", "Brave Browser", url })
      end
    end
    vim.g.mkdp_browserfunc = "OpenMarkdownPreview"
  end,
  keys = {
    { "<leader>m", "", desc = "Markdown", mode = { "n" } },
    {
      "<Leader>md",
      function()
        vim.cmd("MarkdownPreview")
      end,
      desc = "󰈔 Preview markdown",
      mode = { "n" },
    },
    {
      "<Leader>mD",
      function()
        vim.cmd("MarkdownPreviewStop")
      end,
      desc = "󰈔 Stop preview markdown",
      mode = { "n" },
    },
    {
      "<Leader>mt",
      function()
        vim.cmd("MarkdownPreviewToggle")
      end,
      desc = "Preview markdown toggle",
      mode = { "n" },
    },
  },
}
