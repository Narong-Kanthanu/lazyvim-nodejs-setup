return {
  {
    "neovim/nvim-lspconfig",
    dependencies = { "saghen/blink.cmp" },
    opts = function()
      local util = require("lspconfig.util")

      -- Shared inlay hints config for TS/JS
      local ts_js_inlay_hints = {
        parameterNames = { enabled = "none" },
        parameterTypes = { enabled = false },
        variableTypes = { enabled = false },
        propertyDeclarationTypes = { enabled = false },
        functionLikeReturnTypes = { enabled = true },
        enumMemberValues = { enabled = false },
      }

      return {
        inlay_hints = {
          enabled = true,
        },
        servers = {
          vtsls = {
            single_file_support = true,
            root_dir = util.root_pattern("tsconfig.json", "package.json", "jsconfig.json", ".git"),
            settings = {
              typescript = { inlayHints = ts_js_inlay_hints },
              javascript = { inlayHints = ts_js_inlay_hints },
            },
          },
          eslint = {
            settings = {
              workingDirectories = { mode = "auto" },
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
                  groupSeverity = {
                    strong = "Warning",
                    strict = "Warning",
                  },
                  groupFileStatus = {
                    ambiguity = "Opened",
                    await = "Opened",
                    codestyle = "None",
                    duplicate = "Opened",
                    global = "Opened",
                    luadoc = "Opened",
                    redefined = "Opened",
                    strict = "Opened",
                    strong = "Opened",
                    ["type-check"] = "Opened",
                    unbalanced = "Opened",
                    unused = "Opened",
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
            filetypes = { "bash", "sh" },
            settings = {
              bashIde = {
                globPattern = "*@(.sh|.inc|.bash|.command)",
              },
            },
          },
          solargraph = {
            cmd = { "solargraph", "stdio" },
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
          omnisharp = {
            cmd = {
              vim.fn.executable("OmniSharp") == 1 and "OmniSharp" or "omnisharp",
              "--languageserver",
              "--hostPID",
              tostring(vim.fn.getpid()),
              "DotNet:enablePackageRestore=false",
              "--encoding",
              "utf-8",
            },
            filetypes = { "cs" },
            root_markers = { ".sln", ".csproj", "omnisharp.json", "function.json" },
            init_options = {},
            capabilities = {
              workspace = {
                workspaceFolders = false,
              },
            },
          },
        },
      }
    end,
    config = function(_, opts)
      local lspconfig = require("lspconfig")
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      for server, server_opts in pairs(opts.servers) do
        if lspconfig[server] and server ~= "eslint" then
          lspconfig[server].setup(vim.tbl_deep_extend("force", {
            capabilities = capabilities,
          }, server_opts))
        end
      end
    end,
  },
}
