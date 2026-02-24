return {
  "ojroques/nvim-osc52",
  config = function()
    require("osc52").setup({
      max_length = 0, -- No limit
      silent = true,
      trim = false,
      tmux_passthrough = true,
    })

    -- Auto copy to system clipboard on every yank
    vim.api.nvim_create_autocmd("TextYankPost", {
      callback = function()
        if vim.v.event.operator == "y" then
          require("osc52").copy_register("+")
        end
      end,
    })
  end,
}
