#!/usr/bin/env bash
#
# Post-commit cleanup hook for Claude Code.
# Removes the documentation review marker after a successful commit.
#

set -euo pipefail

# Read hook input from stdin
INPUT=$(cat)

# Extract the command from tool_input.command
COMMAND=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))" 2>/dev/null || echo "")

# Only clean up after git commit commands
if ! echo "$COMMAND" | grep -qE '(^|\s|&&|;|\|)\s*git\s+commit(\s|$)'; then
  exit 0
fi

# Remove the marker file
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
PROJECT_HASH=$(echo -n "$PROJECT_DIR" | shasum -a 256 | cut -c1-16)
MARKER_FILE="/tmp/.claude-docs-reviewed-${PROJECT_HASH}"

rm -f "$MARKER_FILE"

exit 0
