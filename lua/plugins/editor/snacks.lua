return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      scroll = { enabled = false },
      image = {
        enabled = true,
        border = "rounded",
        img_dirs = { "img", "images", "assets", "static", "public", "media", "attachments" },
        formats = {
          "png",
          "jpg",
          "jpeg",
          "gif",
          "bmp",
          "webp",
          "tiff",
          "heic",
          "avif",
        },
        icons = {
          math = "󰪚 ",
          chart = "󰄧 ",
          image = " ",
        },
        doc = {
          enabled = false,
          inline = true,
          float = true,
          max_width = 80,
          max_height = 40,
        },
        math = {
          enabled = false,
        },
        convert = {
          notify = true,
          mermaid = function()
            local theme = vim.o.background == "light" and "neutral" or "dark"
            return { "-i", "{src}", "-o", "{file}", "-b", "transparent", "-t", theme, "-s", "{scale}" }
          end,
          magick = {
            default = { "{src}[0]", "-scale", "1920x1080>" }, -- default for raster images
            vector = { "-density", 192, "{src}[0]" }, -- used by vector images like svg
            math = { "-density", 192, "{src}[0]", "-trim" },
          },
        },
      },
      styles = {
        zoom_indicator = {
          text = function()
            local icon = "[ZOOM]"
            local file = vim.fn.expand("%:t")
            return string.format("▍ %s %s", file ~= "" and file or "", icon)
          end,
          minimal = true,
          enter = false,
          focusable = false,
          height = 1,
          row = 0,
          col = -1,
          backdrop = false,
        },
      },
    },
  },
}
