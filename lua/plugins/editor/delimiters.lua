return {
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
      local function line_based_strategy(bufnr, threshold)
        local line_count = vim.api.nvim_buf_line_count(bufnr)
        local strategy = rainbow_delimiters.strategy
        return line_count <= threshold and strategy["global"] or strategy["local"]
      end

      vim.g.rainbow_delimiters = {
        -- define strategy for improve editor performance
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
          vim = rainbow_delimiters.strategy["global"],
          lua = rainbow_delimiters.strategy["global"],
          gitignore = rainbow_delimiters.strategy["global"],
          graphql = rainbow_delimiters.strategy["global"],
          typescript = function(bufnr)
            return line_based_strategy(bufnr, 1000)
          end,
          javascript = function(bufnr)
            return line_based_strategy(bufnr, 1000)
          end,
          json = function(bufnr)
            return line_based_strategy(bufnr, 100000)
          end,
          ruby = function(bufnr)
            return line_based_strategy(bufnr, 1000)
          end,
        },
        -- define query defines what to language match
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
          javascript = "rainbow-parens",
          typescript = "rainbow-parens",
          ruby = "rainbow-delimiters",
        },
        priority = {
          [""] = 100,
          lua = 210,
          javascript = 210,
          typescript = 210,
          ruby = 210,
        },
        highlight = scope_highlight,
      }
      require("ibl").setup({
        scope = {
          char = "▎",
          enabled = true,
          show_start = true,
          show_end = true,
          injected_languages = true,
          highlight = scope_highlight,
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
