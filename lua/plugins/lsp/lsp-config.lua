return {
  {
    "neovim/nvim-lspconfig",
    dependencies = { "saghen/blink.cmp" },
    opts = {
      inlay_hints = {
        enabled = true,
      },
      servers = {
        vtsls = {
          single_file_support = true,
          root_dir = function(...)
            return require("lspconfig.util").root_pattern("tsconfig.json", "package.json", "jsconfig.json", ".git")
          end,
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
          single_file_support = true,
          filetypes = {
            "bash",
            "sh",
          },
          settings = {
            bashIde = {
              globPattern = "*@(.sh|.inc|.bash|.command)",
            },
          },
        },
        solargraph = {
          cmd = {
            { "solargraph", "stdio" },
          },
          filetypes = { "ruby" },
          init_options = {
            formatting = true,
          },
          settings = {
            solargraph = {
              diagnostics = true,
            },
          },
        },
      },
    },
    config = function(_, opts)
      local lspconfig = require("lspconfig")
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      for server, _ in pairs(opts.servers) do
        if server == "vtsls" or server == "html" or server == "lua_ls" or server == "bashls" or server == "solargraph" then
          lspconfig[server].setup({ capabilities = capabilities })
        end
      end
    end,
  },
}
