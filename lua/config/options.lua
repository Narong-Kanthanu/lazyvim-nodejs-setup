vim.scriptencoding = "utf-8"
vim.o.pumblend = 0

local global = vim.g
global.mapleader = " "
global.autoformat = true
global.border_style = "rounded"
global.lazyvim_blink_main = false

local opt = vim.opt
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.number = true
opt.title = true
opt.autoindent = true
opt.smartindent = true
opt.hlsearch = true
opt.backup = false
opt.showcmd = true
opt.cmdheight = 0
opt.laststatus = 0
opt.expandtab = true
opt.scrolloff = 10
opt.inccommand = "split"
opt.ignorecase = true
opt.smarttab = true
opt.breakindent = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.wrap = true
opt.backspace = { "start", "eol", "indent" }
opt.path:append({ "**" })
opt.wildignore:append({ "*/node_modules/*" })
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "cursor"
opt.mouse = ""
opt.formatoptions:append({ "r" })
opt.relativenumber = true
opt.termguicolors = true
opt.confirm = true
opt.cursorline = true
opt.spell = false
