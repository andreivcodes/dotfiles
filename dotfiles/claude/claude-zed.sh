#!/bin/bash

set -euo pipefail

CLAUDE_BIN="${HOME}/.local/bin/claude"
USE_REPO_MCP=true

if [ ! -x "$CLAUDE_BIN" ]; then
  CLAUDE_BIN="${HOME}/.claude/bin/claude"
fi

if [ ! -x "$CLAUDE_BIN" ]; then
  CLAUDE_BIN="$(command -v claude 2>/dev/null || true)"
fi

if [ ! -x "$CLAUDE_BIN" ]; then
  echo "Error: claude not found. Install: curl -fsSL https://claude.ai/install.sh | bash" >&2
  exit 1
fi

for arg in "$@"; do
  case "$arg" in
    --mcp-config|--mcp-config=*)
      USE_REPO_MCP=false
      break
      ;;
  esac
done

if [ "$USE_REPO_MCP" = true ] && [ -f "$HOME/.claude/mcp.json" ]; then
  exec "$CLAUDE_BIN" --mcp-config="$HOME/.claude/mcp.json" "$@"
fi

exec "$CLAUDE_BIN" "$@"
