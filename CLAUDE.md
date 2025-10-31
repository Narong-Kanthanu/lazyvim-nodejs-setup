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
- **options.lua**: Editor settings (2-space indent, no mouse, minimal UI with cmdheight=0)
- **keymaps.lua**: Custom keybindings for window/tab management, LSP, Git, terminals
- **autocmds.lua**: Auto-commands for terminal behavior, diagnostics, OSC52 clipboard

### Plugin Organization

Each plugin module is self-contained with dependencies, lazy-loading conditions, configuration, and keymaps.

#### LSP Configuration (`lua/plugins/lsp/`)

- **lsp-config.lua**: Language servers (vtsls for TS/JS, eslint, lua_ls, bashls)
  - vtsls configured for large monorepos (MaxTsServerMemory: 4096MB, project diagnostics disabled)
  - Root detection: yarn.lock, package.json, tsconfig.json
- **cmp-config.lua**: Completion with blink.cmp (sources: LSP, Copilot, path, snippets, buffer)
  - Copilot integration as completion source
  - Documentation on manual trigger only (`<C-i>`)
- **mason.lua**: Auto-installs LSP servers and tools

#### Editor Plugins (`lua/plugins/editor/`)

- **telescope.lua**: Fuzzy finder with custom layouts and keymaps (`;f`, `;r`, `;d`, etc.)
- **nvim-tree.lua**: File explorer (width: 35, auto-open on startup)
- **treesitter.lua**: Syntax highlighting (disabled for files >500KB)
- **ui.lua**: Status line (lualine), bufferline, notifications (noice, notify), incline
- **colorscheme.lua**: Sonokai theme (shusia variant, transparent background)
- **delimiters.lua**: Rainbow brackets with smart strategy (global for small files, local for large)
- **file-manager.lua**: Yazi integration (`<Leader>fm`)

#### AI Integration (`lua/plugins/ai/`)

- **codecompanion.lua**: Primary AI interface
  - Adapters: claude_code (ACP) and HTTP (Anthropic API, sonnet-4.5)
  - Keymaps: `<Leader>av/as/at` for different chat layouts, `<Leader>aj` for agent in new tab
  - Memory system with common rule files (.clinerules, CLAUDE.md, etc.)
  - MCPHub integration for MCP tools/resources
- **copilot.lua**: GitHub Copilot (manual activation, integrated with blink.cmp)
- **mcphub.lua**: MCP server manager (`<Leader>ah`, port 37373)

#### Git Integration (`lua/plugins/git/`)

- **gitsigns.lua**: Git signs, inline blame, hunk preview
- **lazygit.lua**: LazyGit with telescope extension

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

### LSP
- `gD/gd/gi/gr`: Declaration/definition/implementation/references

### Telescope
- `;f`: Find files
- `;r`: Live grep
- `;d`: Grep in directory
- `\\`: Open buffers
- `;e`: Diagnostics
- `sf`: File browser

### AI Integration
- `<Leader>av/as/at`: AI chat (vertical/horizontal/tab)
- `<Leader>ax`: Send selection to chat
- `<Leader>aj`: New tab with Claude agent
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
- `1-9 + <Tab>`: Jump to buffer N

## Performance Considerations

- **Large files**: Treesitter disabled for files >500KB
- **Monorepos**: vtsls MaxTsServerMemory set to 4096MB, project diagnostics disabled
- **Startup**: Most plugins lazy-loaded on cmd/keys/event
- **Rainbow delimiters**: Smart strategy switches between global/local based on file size

## AI Workflow Notes

- CodeCompanion uses claude_code adapter by default (via ACP)
- Memory system automatically includes context from .clinerules, CLAUDE.md, etc.
- MCP servers can be managed via `<Leader>ah` with auto-toggle based on workspace
- AI chat can be opened in different layouts for different workflows (vertical for side-by-side coding, tab for focus)
- Agent mode (`<Leader>aj`) opens in new tab with custom buffer naming

## Special UI Features

- Transparent backgrounds configured in init.lua
- Rounded borders for all floating windows
- Minimal UI (cmdheight=0, laststatus=0)
- Bufferline styled as tabs with custom formatter for AI Agent tabs
- Incline shows floating filename indicators per window
