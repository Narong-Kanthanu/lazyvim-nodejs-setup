# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a LazyVim-based Neovim configuration optimized for Node.js/TypeScript development with extensive AI integration. The configuration follows a modular architecture with plugin categories organized in separate directories.

## Architecture

### Entry Point & Plugin Management

- **init.lua**: Bootstraps lazy.nvim and requires `config.lazy`
- **lua/config/lazy.lua**: Central plugin manager configuration that imports:
  - LazyVim core + extras (eslint, prettier, typescript, copilot, etc.)
  - Custom plugin modules: `plugins`, `plugins.lsp`, `plugins.git`, `plugins.editor`, `plugins.ai`, `plugins.other`

### Configuration Files

Located in `lua/config/`:
- **options.lua**: Editor settings (2-space indent, no mouse, unnamedplus clipboard, minimal UI with cmdheight=0, laststatus=0)
- **keymaps.lua**: Custom keybindings for window/tab management, LSP, Git, terminals
- **autocmds.lua**: Auto-commands for terminal behavior, diagnostics config, macro performance

### Plugin Organization

Each plugin module is self-contained with dependencies, lazy-loading conditions, configuration, and keymaps.

#### LSP Configuration (`lua/plugins/lsp/`)

- **lsp-config.lua**: Language servers (vtsls for TS/JS, eslint, lua_ls, bashls, html)
  - vtsls configured for large monorepos (MaxTsServerMemory: 4096MB, project diagnostics disabled)
  - Root detection: yarn.lock, package.json, tsconfig.json, .git
  - Inlay hints limited to function return types only
- **cmp-config.lua**: Completion with blink.cmp (sources: LSP, Copilot, path, snippets, buffer)
  - Copilot integration as completion source (blink-cmp-copilot)
  - Documentation on manual trigger only (`<C-i>`)
  - Ghost text completion when AI completion disabled
  - Custom keymaps: `<C-j/k>` navigation, `<C-h/l>` doc scroll
- **mason.lua**: Auto-installs LSP servers and tools (lua-language-server, shellcheck, shfmt, vtsls, bash-language-server, omnisharp)

#### Editor Plugins (`lua/plugins/editor/`)

- **telescope.lua**: Fuzzy finder with custom layouts and keymaps (`;f`, `;r`, `;d`, etc.)
  - FZF native integration for performance
  - Undo extension with side-by-side preview
- **nvim-tree.lua**: File explorer (width: 35, auto-open on startup, filters dotfiles and node_modules)
- **treesitter.lua**: Syntax highlighting via `vim.treesitter.start()` (disabled for files >500KB, skips special buffers), treesitter-based folding, auto-tag as standalone plugin
- **ui.lua**: Status line (lualine), bufferline, notifications (noice, notify), incline
- **colorscheme.lua**: Sonokai theme (shusia variant, transparent background)
- **delimiters.lua**: Rainbow brackets with smart strategy (global for ≤1000 lines, local for larger)
- **file-manager.lua**: Yazi integration (`<Leader>fm`)
- **flash.lua**: Jump navigation (`s` to jump, `S` for treesitter jump)
- **editor.lua**: TODO comments with navigation (`tj/tk`) and search (`<Leader>td/tf`), mini.hipatterns (hex color highlighting)
- **snacks.nvim**: Image preview (PNG, JPG, GIF, WebP), zoom mode (`<Leader>zz`), mermaid support

#### AI Integration (`lua/plugins/ai/`)

- **codecompanion.lua**: Primary AI interface
  - Adapters: copilot (claude-sonnet-4.5 primary), claude_code (ACP), anthropic (HTTP)
  - Keymaps: `<Leader>av/as/at` for different chat layouts, `<Leader>ag` for agent in new tmux window
  - Memory system with common rule files (.clinerules, .cursorrules, .goosehints, CLAUDE.md, AGENT.md, etc.)
  - MCPHub integration for MCP tools/resources
  - Chat keymaps: `<C-s>` send, `<C-c>` close, `<C-l>` clear
- **copilot.lua**: GitHub Copilot (manual trigger, integrated with blink.cmp)
- **mcphub.lua**: MCP server manager (`<Leader>ah`, port 37373)
  - Workspace-local config: .mcphub/servers.json, .vscode/mcp.json

#### Git Integration (`lua/plugins/git/`)

- **gitsigns.lua**: Git signs, inline blame (1000ms delay), hunk preview, staged change signs
- **lazygit.lua**: LazyGit with telescope extension

#### Other Plugins (`lua/plugins/other/`)

- **clipboard.lua**: OSC52 clipboard support for SSH/remote development (auto-copies on yank)
- **which-key.lua**: Keymap display helper with modern preset
- **peek.lua**: Markdown preview with webview (`<Leader>md` open, `<Leader>mq` close)

#### Refactoring (`lua/plugins/refactoring.lua`)

- **inc-rename.nvim**: Incremental rename (`<Leader>rn`)
- **refactoring.nvim**: Refactoring menu (`<Leader>r` in visual mode)

## Key Keybindings

### Window Management
- `ss/sv`: Horizontal/vertical split
- `sh/sk/sj/sl`: Navigate windows
- `<C-S-h/l/k/j>`: Resize windows

### Tab Management
- `te`: Edit in new tab
- `ta`: New tab
- `tw`: Close tab

### Terminal
- `tt/ts/tv`: Terminal in tab/horizontal/vertical split
- `<Esc>`: Exit terminal mode

### LSP
- `gD/gd/gi/gr`: Declaration/definition/implementation/references
- `<Leader>ca`: Code actions
- `<Leader>rn`: Incremental rename
- `<Leader>cm`: Open Mason UI

### Telescope
- `;f`: Find files
- `;r`: Live grep
- `;d`: Grep in directory (interactive)
- `;m`: Marks
- `\\`: Open buffers
- `;;`: Resume last search
- `;e`: Diagnostics
- `;s`: Treesitter symbols
- `;u`: Undo history
- `sf`: File browser

### AI Integration
- `<Leader>av/as/at`: AI chat (vertical/horizontal/tab)
- `<Leader>ax`: Send selection to chat (visual mode)
- `<Leader>ag`: New tmux window with Claude Code CLI agent
- `<Leader>ah`: MCP manager

### Git
- `<Leader>gh`: Preview hunk
- `<Leader>gt`: Toggle blame
- `<Leader>gb`: Git blame

### File Explorer
- `<Leader>fe`: Open nvim-tree
- `<Leader>fm`: Open Yazi file manager

### Bufferline
- `<Tab>/<S-Tab>`: Next/previous buffer
- `1-9<Tab>`: Jump to buffer N

### Flash (Jump Navigation)
- `s`: Jump to text
- `S`: Treesitter-based jump
- `r`: Remote flash (operator mode)
- `R`: Treesitter search
- `<C-s>`: Toggle in command mode

### TODO Comments
- `tj/tk`: Next/previous TODO comment
- `<Leader>td`: TODO search in current file
- `<Leader>tf`: TODO search in project root

### Markdown
- `<Leader>md`: Open markdown preview
- `<Leader>mq`: Close markdown preview

### Refactoring
- `<Leader>rn`: Incremental rename
- `<Leader>r`: Refactoring menu (visual mode)

### UI
- `<Leader>zz`: Zoom mode toggle

### General
- `x`: Delete without copying
- `+/-`: Increment/decrement numbers
- `<C-a>`: Select all
- `<Leader>qq`: Quit current window
- `<Leader>qQ`: Quit all windows

## Performance Considerations

- **Large files**: Treesitter disabled for files >500KB
- **Monorepos**: vtsls MaxTsServerMemory set to 4096MB, project diagnostics disabled
- **Startup**: Most plugins lazy-loaded on cmd/keys/event
- **Rainbow delimiters**: Smart strategy (global for ≤1000 lines, local for larger files)
- **Git signs**: Max file size 40000 lines
- **Memory management**: Garbage collection tuning in options.lua
- **Macro recording**: Lazyredraw enabled for performance during macros
- **Diagnostics**: Virtual text disabled, severity sorting enabled

## AI Workflow Notes

- CodeCompanion uses copilot adapter (claude-sonnet-4.5) by default
- Memory system automatically includes context from:
  - .clinerules, .cursorrules, .goosehints, .rules
  - .github/copilot-instructions.md
  - CLAUDE.md, CLAUDE.local.md, ~/.claude/CLAUDE.md
  - AGENT.md, AGENTS.md
- MCP servers can be managed via `<Leader>ah` with auto-toggle based on workspace
- Workspace MCP config: .mcphub/servers.json, .vscode/mcp.json
- AI chat can be opened in different layouts for different workflows (vertical for side-by-side coding, tab for focus)
- Agent mode (`<Leader>ag`) launches Claude Code CLI in a new tmux window named " _agent" with the current working directory

## Special UI Features

- Transparent backgrounds configured in init.lua
- Rounded borders for all floating windows
- Minimal UI (cmdheight=0, laststatus=0)
- Bufferline styled as tabs with special formatting for AI chat buffers
- Incline shows floating filename indicators per window
- Noice.nvim for enhanced messages and command line
- nvim-notify for notifications (2500ms timeout)

## Claude Code Hooks

Project-level hooks in `.claude/settings.json` enforce documentation hygiene:

- **PreToolUse hook** (`.claude/hooks/pre-commit-doc-check.sh`): Blocks `git commit` until CLAUDE.md has been reviewed. Creates a marker file in `/tmp/` per-project to track review status.
- **PostToolUse hook** (`.claude/hooks/post-commit-cleanup.sh`): Removes the marker after a successful commit so the next commit triggers a fresh review.
- **Flow**: Commit blocked → Claude reviews staged changes → updates CLAUDE.md if needed → creates marker → retries commit → marker cleaned up after success.
- Local overrides via `.claude/settings.local.json` (gitignored).

## Remote Development

- OSC52 clipboard integration for SSH clipboard sync
- Tmux passthrough enabled for clipboard operations
- Automatic copy on yank operations
