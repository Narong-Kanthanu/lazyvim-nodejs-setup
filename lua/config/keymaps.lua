local keymap = vim.keymap
local opts = { noremap = true, silent = true }

keymap.set("n", "x", '"_x')

-- Increment/decrement
keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G") -- hold the Control and a to selecte all.

-- Save file and quit
keymap.set("n", "<Leader>qq", ":quit<Return>", opts)
keymap.set("n", "<Leader>qQ", ":qa<Return>", opts)

-- File explorer with NvimTree
keymap.set("n", "<Leader>ff", ":NvimTreeFindFileToggle<Return>", opts)

-- Tabs
keymap.set("n", "ta", ":tabedit ")
keymap.set("n", "te", ":tabedit<Return>")
keymap.set("n", "tw", ":tabclose<Return>", opts)

-- Split window
keymap.set("n", "ss", ":split<Return>", opts)
keymap.set("n", "sv", ":vsplit<Return>", opts)

-- Move window
keymap.set("n", "sh", "<C-w>h")
keymap.set("n", "sk", "<C-w>k")
keymap.set("n", "sj", "<C-w>j")
keymap.set("n", "sl", "<C-w>l")

-- Resize window
keymap.set("n", "<C-S-h>", "<C-w><")
keymap.set("n", "<C-S-l>", "<C-w>>")
keymap.set("n", "<C-S-k>", "<C-w>+")
keymap.set("n", "<C-S-j>", "<C-w>-")

-- Terminal
keymap.set("n", "tm", ":tabnew | term<Return>", opts)
keymap.set("n", "ts", ":sp | term<Return>", opts)
keymap.set("n", "tv", ":vsp | term<Return>", opts)

-- Diagnostics
keymap.set("n", "<C-j>", function()
  vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR, wrap = true })
end, opts)
keymap.set("n", "<C-k>", function()
  vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR, wrap = true })
end, opts)

-- Bookmarks
opts.desc = "Mark current line into active BookmarkList."
keymap.set({ "n", "v" }, "mm", ":BookmarksMark<Return>", opts)
opts.desc = "Go to bookmark at current active BookmarkList."
keymap.set({ "n", "v" }, "mo", ":BookmarksGoto<Return>", opts)
opts.desc = "Find and trigger a bookmark command."
keymap.set({ "n", "v" }, "ma", ":BookmarksCommands<Return>", opts)
opts.desc = "Go to latest visited/created Bookmark"
keymap.set({ "n", "v" }, "mg", ":BookmarksGotoRecent<Return>", opts)

-- Go implementation.
keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go implementation" })

-- Git
keymap.set("n", "<Leader>gh", ":Gitsigns preview_hunk<Return>", opts)
keymap.set("n", "<Leader>gt", ":Gitsigns toggle_current_line_blame<Return>", opts)
keymap.set("n", "<Leader>gb", ":Git blame<Return>", opts)
