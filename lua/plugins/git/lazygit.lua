return {
  -- LazyGit integration with Telescope
  "kdheepak/lazygit.nvim",
  lazy = true,
  keys = {},
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("telescope").load_extension("lazygit")
  end,
}
