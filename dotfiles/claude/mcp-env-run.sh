#!/bin/bash

set -euo pipefail

if [ "$#" -eq 0 ]; then
  echo "Usage: mcp-env-run.sh <command> [args...]" >&2
  exit 64
fi

export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:$HOME/.claude/bin:$PATH"

# Load Homebrew, private MCP keys, and NVM for GUI-launched clients such as
# Claude Desktop, which do not inherit an interactive shell environment.
# shellcheck source=/dev/null
source "$HOME/.zprofile" 2>/dev/null || true
# shellcheck source=/dev/null
source "$HOME/.zshrc.local" 2>/dev/null || true

NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  # shellcheck source=/dev/null
  source "$NVM_DIR/nvm.sh" 2>/dev/null || true
  nvm use --silent default >/dev/null 2>&1 || true
fi

if ! command -v "$1" >/dev/null 2>&1; then
  echo "Error: command not found for MCP server: $1" >&2
  exit 127
fi

exec "$@"
