#!/bin/bash

set -euo pipefail

# shellcheck source=/dev/null
source "$HOME/.zprofile" 2>/dev/null || true
# shellcheck source=/dev/null
source "$HOME/.zshrc.local" 2>/dev/null || true

if [ -s "$HOME/.nvm/nvm.sh" ]; then
  # shellcheck source=/dev/null
  source "$HOME/.nvm/nvm.sh" 2>/dev/null || true
fi

PI_ACP_BIN="$(command -v pi-acp 2>/dev/null || true)"
if [ -n "$PI_ACP_BIN" ] && [ -x "$PI_ACP_BIN" ]; then
  exec "$PI_ACP_BIN" "$@"
fi

NPX_BIN="$(command -v npx 2>/dev/null || true)"
if [ -n "$NPX_BIN" ] && [ -x "$NPX_BIN" ]; then
  exec "$NPX_BIN" -y pi-acp "$@"
fi

echo "Error: pi-acp not found. Install: npm install -g pi-acp" >&2
exit 1
