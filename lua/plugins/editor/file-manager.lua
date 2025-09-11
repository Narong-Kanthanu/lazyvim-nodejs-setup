return {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  dependencies = {
    { "nvim-lua/plenary.nvim", lazy = true },
  },
  keys = {
    {
      "<leader>fm",
      mode = { "n", "v" },
      "<cmd>Yazi cwd<cr>",
      desc = "Open file manager",
    },
    opts = {
      open_for_directories = false,
      open_multiple_tabs = false,
      highlight_hovered_buffers_in_same_directory = true,
      floating_window_scaling_factor = 0.5,
      yazi_floating_window_winblend = 0,
      yazi_floating_window_border = "rounded",
      keymaps = {
        show_help = "<f1>",
        open_file_in_vertical_split = "<c-v>",
        open_file_in_horizontal_split = "<c-s>",
        open_file_in_tab = "<c-t>",
        grep_in_directory = "<c-f>",
        replace_in_directory = "<c-g>",
        cycle_open_buffers = "<tab>",
        copy_relative_path_to_selected_files = "<c-y>",
        send_to_quickfix_list = "<c-q>",
        change_working_directory = "<c-\\>",
      },
    },
  },
}
