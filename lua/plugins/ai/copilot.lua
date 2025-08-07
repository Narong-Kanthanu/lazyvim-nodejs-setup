return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  build = ":Copilot auth",
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      suggestion = {
        enabled = not vim.g.ai_cmp,
        auto_trigger = false,
        hide_during_completion = true,
      },
      panel = {
        enabled = false,
      },
      filetypes = {
        ["*"] = true, -- default enabled all file types
      },
    })
  end,
}
