return {
  "ravitemer/mcphub.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  build = "npm install -g mcp-hub@latest",
  config = function()
    require("mcphub").setup({
      config = vim.fn.expand("~/.config/mcphub/servers.json"), -- Absolute path to MCP Servers config file (will create if not exists)
      port = 37373,
      shutdown_delay = 5 * 60 * 000, -- Delay in ms before shutting down the server when last instance closes (default: 5 minutes)
      mcp_request_timeout = 60000, --Max time allowed for a MCP tool or resource to execute in milliseconds
      auto_approve = false, -- Auto approve mcp tool calls
      auto_toggle_mcp_servers = true,
      workspace = {
        enabled = true, -- Enable project-local configuration files
        look_for = { ".mcphub/servers.json", ".vscode/mcp.json", ".cursor/mcp.json" }, -- Files to look for when detecting project boundaries (VS Code format supported)
        reload_on_dir_changed = true,
        port_range = { min = 40000, max = 41000 },
        get_port = nil,
      },
      ui = {
        window = {
          width = 0.8,
          height = 0.8,
          align = "center", -- "center", "top-left", "top-right", "bottom-left", "bottom-right", "top", "bottom", "left", "right"
          relative = "editor",
          zindex = 50,
          border = "rounded",
        },
        wo = { -- window-scoped options (vim.wo)
          winhl = "Normal:MCPHubNormal,FloatBorder:MCPHubBorder",
        },
        on_ready = function(hub)
          -- Called when hub is ready
        end,
        on_error = function(err)
          -- Called on errors
        end,
      },
    })
  end,
}
