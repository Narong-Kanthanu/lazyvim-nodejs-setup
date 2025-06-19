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

-- Tabs
keymap.set("n", "ta", ":tabedit ")
keymap.set("n", "te", ":tabedit<Return>", opts)
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
keymap.set("n", "tt", ":tabnew | term<Return>", opts)
keymap.set("n", "ts", ":sp | term<Return>", opts)
keymap.set("n", "tv", ":vsp | term<Return>", opts)
keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)

-- Diagnostics
keymap.set("n", "<C-j>", function()
  vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR, wrap = true })
end, opts)
keymap.set("n", "<C-k>", function()
  vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR, wrap = true })
end, opts)

-- Go to definition
keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go declaration" })
keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go definition" })
keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go implementation" })
keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Go references" })

-- Git
keymap.set("n", "<Leader>gh", ":Gitsigns preview_hunk<Return>", opts)
keymap.set("n", "<Leader>gt", ":Gitsigns toggle_current_line_blame<Return>", opts)
keymap.set("n", "<Leader>gb", ":Git blame<Return>", opts)

-- Markdown preview
keymap.set("n", "<Leader>md", ":MarkdownPreview<Return>", opts)
keymap.set("n", "<Leader>mD", ":MarkdownPreviewStop<Return>", opts)
keymap.set("n", "<Leader>mt", ":MarkdownPreviewToggle<Return>", opts)
