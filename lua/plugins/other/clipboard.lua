return {
  {
    "ojroques/nvim-osc52",
    config = function()
      require("osc52").setup({
        max_length = 0, -- No limit
        silent = true,
        trim = false,
        tmux_passthrough = true,
      })
    end,
  },
}
