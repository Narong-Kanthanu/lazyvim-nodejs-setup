return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup()

      require("nvim-treesitter").install({
        "javascript",
        "typescript",
        "gitignore",
        "graphql",
        "http",
        "json",
        "vim",
        "vimdoc",
        "lua",
        "xml",
        "markdown",
        "markdown_inline",
        "c_sharp",
      })

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("TreesitterFeatures", { clear = true }),
        pattern = "*",
        callback = function(args)
          local buf = args.buf

          -- Skip special buffers (terminals, prompts, plugin UIs)
          if vim.bo[buf].buftype ~= "" then
            return
          end

          -- Skip large files
          local max_filesize = 500 * 1024 -- 500 KB
          local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return
          end

          -- Only enable if a parser exists for this filetype
          local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
          if not lang or not pcall(vim.treesitter.language.inspect, lang) then
            return
          end

          vim.treesitter.start(buf)
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

          -- Treesitter-based folding
          vim.wo[0][0].foldmethod = "expr"
          vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
          vim.wo[0][0].foldlevel = 99
        end,
      })
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },
}
