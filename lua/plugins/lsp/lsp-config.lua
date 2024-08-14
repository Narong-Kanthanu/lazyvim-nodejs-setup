return {
  -- lsp servers config
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = {
        enabled = true,
      },
      servers = {
        vtsls = {
          root_dir = function(...)
            return require("lspconfig.util").root_pattern("tsconfig.json", "package.json", "jsconfig.json", ".git")
          end,
          single_file_support = true,
          settings = {
            typescript = {
              inlayHints = {
                parameterNames = { enabled = "none" }, -- 'none' | 'literals' | 'all'
                parameterTypes = { enabled = false },
                variableTypes = { enabled = false },
                propertyDeclarationTypes = { enabled = false },
                functionLikeReturnTypes = { enabled = true },
                enumMemberValues = { enabled = false },
              },
            },
            javascript = {
              inlayHints = {
                parameterNames = { enabled = "none" }, -- 'none' | 'literals' | 'all'
                parameterTypes = { enabled = false },
                variableTypes = { enabled = false },
                propertyDeclarationTypes = { enabled = false },
                functionLikeReturnTypes = { enabled = true },
                enumMemberValues = { enabled = false },
              },
            },
          },
        },
        html = {},
        lua_ls = {
          single_file_support = true,
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                workspaceWord = true,
                callSnippet = "Both",
              },
              misc = {
                parameters = {
                  -- "--log-level=trace",
                },
              },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
              doc = {
                privateName = { "^_" },
              },
              type = {
                castNumberToInteger = true,
              },
              diagnostics = {
                disable = { "incomplete-signature-doc", "trailing-space" },
                -- enable = false,
                groupSeverity = {
                  strong = "Warning",
                  strict = "Warning",
                },
                groupFileStatus = {
                  ["ambiguity"] = "Opened",
                  ["await"] = "Opened",
                  ["codestyle"] = "None",
                  ["duplicate"] = "Opened",
                  ["global"] = "Opened",
                  ["luadoc"] = "Opened",
                  ["redefined"] = "Opened",
                  ["strict"] = "Opened",
                  ["strong"] = "Opened",
                  ["type-check"] = "Opened",
                  ["unbalanced"] = "Opened",
                  ["unused"] = "Opened",
                },
                unusedLocalExclude = { "_*" },
              },
              format = {
                enable = false,
                defaultConfig = {
                  indent_style = "space",
                  indent_size = "2",
                  continuation_indent_size = "2",
                },
              },
            },
          },
        },
        bashls = {
          settings = {
            filetypes = {
              "sh",
              "zsh",
            },
          },
        },
      },
      setup = {
        vtsls = function(_, opts)
          require("typescript").setup(opts)
        end,
      },
    },
    -- completion engine
    {
      "nvim-cmp",
      dependencies = { "hrsh7th/cmp-emoji" },
      opts = function(_, opts)
        local cmp = require("cmp")
        opts.window = {
          completion = {
            border = "rounded",
            side_padding = 0,
            winhighlight = "Normal:BorderBG,FloatBorder:BorderBG,CursorLine:PmenuSel,Search:None",
          },
          documentation = {
            border = "rounded",
            side_padding = 0,
            winhighlight = "Normal:BorderBG,FloatBorder:BorderBG,CursorLine:PmenuSel,Search:None",
          },
        }
        opts.mapping = cmp.mapping.preset.insert({
          ["<C-j>"] = cmp.mapping.select_next_item(),
          ["<C-k>"] = cmp.mapping.select_prev_item(),
          ["<C-h>"] = cmp.mapping.scroll_docs(-4),
          ["<C-l>"] = cmp.mapping.scroll_docs(4),
          ["<Tab>"] = cmp.mapping.confirm({ select = false }),
        })
        cmp.setup(opts)
        table.insert(opts.sources, { name = "emoji" })
      end,
    },
  },
}
