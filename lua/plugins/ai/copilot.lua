return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = false,
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
  },
}
