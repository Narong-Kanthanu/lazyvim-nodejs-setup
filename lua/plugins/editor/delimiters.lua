return {
  -- blankline
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
  -- rainbow delimiters
  {
    "HiPhish/rainbow-delimiters.nvim",
    config = function()
      local rainbow_delimiters = require("rainbow-delimiters")
      local hooks = require("ibl.hooks")

      -- Colors for scope highlights
      local scope_colors = {
        RainbowRed = "#E06C75",
        RainbowYellow = "#E5C07B",
        RainbowBlue = "#61AFEF",
        RainbowOrange = "#D19A66",
        RainbowGreen = "#98C379",
        RainbowViolet = "#C678DD",
        RainbowCyan = "#56B6C2",
      }

      local indent_highlight = { "DimGray" }

      -- Setup highlight groups
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        for group, color in pairs(scope_colors) do
          vim.api.nvim_set_hl(0, group, { fg = color })
        end
        vim.api.nvim_set_hl(0, "DimGray", { fg = "#333333" })
      end)

      -- Strategy helper function
      local function smart_strategy(max_lines)
        return function(bufnr)
          local line_count = vim.api.nvim_buf_line_count(bufnr)
          return line_count <= max_lines and rainbow_delimiters.strategy["global"] or rainbow_delimiters.strategy["local"]
        end
      end

      -- Rainbow delimiters config
      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow_delimiters.strategy.global,
          vim = rainbow_delimiters.strategy.global,
          lua = rainbow_delimiters.strategy.global,
          gitignore = rainbow_delimiters.strategy.global,
          graphql = rainbow_delimiters.strategy.global,
          typescript = smart_strategy(1000),
          javascript = smart_strategy(1000),
          json = smart_strategy(100000),
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
          javascript = "rainbow-parens",
          typescript = "rainbow-parens",
        },
        priority = {
          [""] = 100,
          lua = 210,
          javascript = 210,
          typescript = 210,
        },
        highlight = vim.tbl_keys(scope_colors),
      }

      -- IBL setup
      require("ibl").setup({
        scope = {
          char = "▎",
          enabled = true,
          show_start = true,
          show_end = true,
          injected_languages = true,
          highlight = vim.tbl_keys(scope_colors),
        },
        indent = {
          char = "▎",
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
