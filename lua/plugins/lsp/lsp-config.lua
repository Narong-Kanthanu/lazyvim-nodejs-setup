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
            cmd = { "vtsls", "--stdio" },
            single_file_support = false,
            filetypes = {
              "typescript",
              "javascript",
            },
            root_dir = util.root_pattern("yarn.lock", "package-lock.json", "tsconfig.base.json", "tsconfig.json", "package.json", "jsconfig.json", ".git"),
            settings = {
              typescript = {
                inlayHints = ts_js_inlay_hints,
                tsserver = {
                  maxTsServerMemory = 4096, -- increase for large monorepos
                  useSyntaxServer = "auto", -- balance performance
                },
                format = {
                  enable = true,
                },
              },
              javascript = {
                inlayHints = ts_js_inlay_hints,
                tsserver = {
                  maxTsServerMemory = 4096,
                },
              },
              completions = {
                completeFunctionCalls = true,
              },
              experimental = {
                enableProjectDiagnostics = false, -- turn off per-project diagnostics (faster)
              },
            },
            init_options = {
              disableSuggestions = true, -- don’t spam suggestions from tsserver
              preferences = {
                includeCompletionsForModuleExports = true,
                includeCompletionsWithInsertText = true,
              },
            },
            on_init = function(client)
              -- Fix stuck initialize loop by notifying configuration change
              client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
            end,
          },
          eslint = {
            cmd = { "vscode-eslint-language-server", "--stdio" },
            filetypes = {
              "typescript",
              "javascript",
            },
            root_dir = function(bufnr, on_dir)
              local root_file_patterns = {
                ".eslintrc",
                ".eslintrc.js",
                ".eslintrc.cjs",
                ".eslintrc.yaml",
                ".eslintrc.yml",
                ".eslintrc.json",
                "eslint.config.js",
                "eslint.config.mjs",
                "eslint.config.cjs",
                "eslint.config.ts",
                "eslint.config.mts",
                "eslint.config.cts",
              }
              local fname = vim.api.nvim_buf_get_name(bufnr)
              root_file_patterns = util.insert_package_json(root_file_patterns, "eslintConfig", fname)
              on_dir(vim.fs.dirname(vim.fs.find(root_file_patterns, { path = fname, upward = true })[1]))
            end,
            settings = {
              workingDirectories = { mode = "auto" },
            },
          },
          html = {},
          lua_ls = {
            cmd = { "lua-language-server" },
            single_file_support = true,
            filetypes = { "lua" },
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
          -- omnisharp = {
          --   cmd = {
          --     vim.fn.executable("OmniSharp") == 1 and "OmniSharp" or "omnisharp",
          --     "--languageserver",
          --     "--hostPID",
          --     tostring(vim.fn.getpid()),
          --     "--encoding",
          --     "utf-8",
          --     "--config:DotNet:enablePackageRestore=false",
          --   },
          --   filetypes = { "cs" },
          --   root_dir = util.root_pattern("*.sln", "*.csproj", ".git"),
          --   capabilities = vim.lsp.protocol.make_client_capabilities(),
          --   enable_roslyn_analyzers = false,
          --   organize_imports_on_format = true,
          --   enable_import_completion = true,
          -- },
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
