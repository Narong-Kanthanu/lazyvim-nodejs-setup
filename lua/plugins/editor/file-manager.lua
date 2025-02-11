return {
  "mikavilpas/yazi.nvim",
  event = "VeryLazy",
  keys = {
    {
      "<leader>fi",
      mode = { "n", "v" },
      "<cmd>Yazi<cr>",
      desc = "Open file manager",
    },
    opts = {
      open_for_directories = false,
      open_multiple_tabs = false,
      highlight_hovered_buffers_in_same_directory = true,
      floating_window_scaling_factor = 1,
      keymaps = {
        show_help = "<f1>",
        open_file_in_vertical_split = "<c-v>",
        open_file_in_horizontal_split = "<c-x>",
        open_file_in_tab = "<c-t>",
        grep_in_directory = "<c-s>",
        replace_in_directory = "<c-g>",
        cycle_open_buffers = "<tab>",
        copy_relative_path_to_selected_files = "<c-y>",
        send_to_quickfix_list = "<c-q>",
        change_working_directory = "<c-\\>",
      },
    },
  },
}
