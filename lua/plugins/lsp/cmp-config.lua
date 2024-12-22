return {
  {
    "saghen/blink.cmp",
    opts_extend = {
      "sources.completion.enabled_providers",
      "sources.compat",
      "sources.default",
    },
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
        use_nvim_cmp_as_default = false,
        kind_icons = {
          Copilot = "",
          Text = "󰉿",
          Method = "󰊕",
          Function = "󰊕",
          Constructor = "󰒓",

          Field = "󰜢",
          Variable = "󰆦",
          Property = "󰖷",

          Class = "󱡠",
          Interface = "󱡠",
          Struct = "󱡠",
          Module = "󰅩",

          Unit = "󰪚",
          Value = "󰦨",
          Enum = "󰦨",
          EnumMember = "󰦨",

          Keyword = "󰻾",
          Constant = "󰏿",

          Snippet = "󱄽",
          Color = "󰏘",
          File = "󰈔",
          Reference = "󰬲",
          Folder = "󰉋",
          Event = "󱐋",
          Operator = "󰪚",
          TypeParameter = "󰬛",
        },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "copilot" },
        providers = {
          copilot = {
            name = "copilot",
            module = "blink-cmp-copilot",
            score_offset = 100,
            async = true,
            transform_items = function(_, items)
              local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
              local kind_idx = #CompletionItemKind + 1
              CompletionItemKind[kind_idx] = "Copilot"
              for _, item in ipairs(items) do
                item.kind = kind_idx
              end
              return items
            end,
          },
        },
        compat = {},
      },
      snippets = {
        expand = function(snippet, _)
          return LazyVim.cmp.expand(snippet)
        end,
      },
      completion = {
        documentation = {
          auto_show = false,
          auto_show_delay_ms = 200,
          treesitter_highlighting = false,
          window = {
            border = "rounded",
            winblend = 0,
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
          winblend = 0,
          winhighlight = "Normal:BorderBG,FloatBorder:BorderBG,CursorLine:PmenuSel,Search:None",
        },
        accept = {
          auto_brackets = {
            enabled = true,
          },
        },
      },
      keymap = {
        preset = "none",
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
        ["<C-i>"] = { "show", "show_documentation", "hide_documentation" },
      },
    },
  },
}
