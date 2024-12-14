return {
  {
    "saghen/blink.cmp",
    dependencies = {
      "rafamadriz/friendly-snippets",
      {
        "giuxtaposition/blink-cmp-copilot",
      },
      {
        "saghen/blink.compat",
        optional = true, -- make optional so it's only enabled if any extras need it
        opts = {},
        version = not vim.g.lazyvim_blink_main and "*",
      },
    },
    event = "InsertEnter",
    opts = {
      appearance = {
        -- Sets the fallback highlight groups to nvim-cmp's highlight groups
        -- Useful for when your theme doesn't support blink.cmp
        -- will be removed in a future release
        use_nvim_cmp_as_default = true,
      },
      sources = {
        providers = {
          copilot = {
            name = "copilot",
            module = "blink-cmp-copilot",
          },
        },
        completion = {
          enabled_providers = { "lsp", "path", "snippets", "buffer", "copilot" },
        },
      },
      completion = {
        documentation = {
          auto_show = false,
          auto_show_delay_ms = 200,
          treesitter_highlighting = false,
          window = {
            border = "rounded",
            padding = 0,
            winhighlight = "Normal:BorderBG,FloatBorder:BorderBG,CursorLine:PmenuSel,Search:None",
          },
        },
        ghost_text = {
          enabled = not vim.g.ai_cmp,
        },
        menu = {
          enabled = true,
          auto_show = true,
          draw = {
            treesitter = {},
          },
          border = "rounded",
          padding = 0,
          winhighlight = "Normal:BorderBG,FloatBorder:BorderBG,CursorLine:PmenuSel,Search:None",
        },
        accept = {
          auto_brackets = {
            enabled = true,
          },
        },
      },
      keymap = {
        preset = "super-tab",
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },
        ["<C-h>"] = { "scroll_documentation_down", "fallback" },
        ["<C-l>"] = { "scroll_documentation_up", "fallback" },
        ["<Tab>"] = {
          function(cmp)
            if cmp.snippet_active() then
              return cmp.accept()
            else
              return cmp.select_and_accept()
            end
          end,
          "snippet_forward",
          "fallback",
        },
        ["<CR>"] = { "show", "show_documentation", "hide_documentation" },
      },
    },
  },
}
