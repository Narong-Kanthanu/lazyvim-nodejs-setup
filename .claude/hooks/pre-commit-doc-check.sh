#!/usr/bin/env bash
#
# Pre-commit documentation check hook for Claude Code.
# Blocks git commit commands until CLAUDE.md has been reviewed and updated.
#
# Protocol:
#   - Reads JSON from stdin (Claude Code hook input)
#   - Checks if the command is a git commit
#   - If marker file exists → exit 0 (allow)
#   - If no marker → exit 2 (block with instructions)
#

set -euo pipefail

# Read hook input from stdin
INPUT=$(cat)

# Extract the command from tool_input.command
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null || echo "")

# Check if this is a git commit command
# Handles: git commit, git commit -m, and chained commands like git add . && git commit
if ! echo "$COMMAND" | grep -qE '(^|\s|&&|;|\|)\s*git\s+commit(\s|$)'; then
  exit 0
fi

# Generate a project-specific marker using a hash of the project directory
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
PROJECT_HASH=$(echo -n "$PROJECT_DIR" | shasum -a 256 | cut -c1-16)
MARKER_FILE="/tmp/.claude-docs-reviewed-${PROJECT_HASH}"

# If marker exists, docs have been reviewed — allow the commit
if [[ -f "$MARKER_FILE" ]]; then
  exit 0
fi

# Block the commit and instruct Claude to review docs first
cat >&2 <<'INSTRUCTIONS'
DOCUMENTATION REVIEW REQUIRED before committing.

Please follow these steps:

1. Run `git diff --cached` to review all staged changes
2. Read the current CLAUDE.md file
3. Check if any of these areas changed and update CLAUDE.md accordingly:
   - Plugin additions, removals, or configuration changes
   - Keybinding additions or modifications
   - Architecture or file structure changes
   - LSP or completion configuration changes
   - AI integration changes
   - Performance-related changes
   - UI/theme changes
4. Update memory files if persistent patterns were discovered
5. Stage any documentation changes: `git add CLAUDE.md`
6. Create the review marker by running:
INSTRUCTIONS

echo "   touch $MARKER_FILE" >&2

cat >&2 <<'INSTRUCTIONS2'
7. Retry the commit command

If no documentation changes are needed, still create the marker file to confirm you reviewed the changes.
INSTRUCTIONS2

exit 2
