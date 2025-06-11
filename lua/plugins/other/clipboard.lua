return {
  {
    "ojroques/nvim-osc52",
    config = function()
      require("osc52").setup({
        max_length = 0, -- No limit
        silent = false,
        trim = false,
      })
    end,
  },
}
