#!/bin/bash

set -euo pipefail

# Claude Code status line script
# Displays: directory, model

if ! command -v jq >/dev/null 2>&1; then
    printf '%s\n' "${PWD##*/}"
    exit 0
fi

input=$(cat)
model=$(jq -r '.model.display_name // "unknown"' <<<"$input")
dir=$(jq -r '.workspace.current_dir // "."' <<<"$input")
dir="${dir/#$HOME/~}"
dir="${dir##*/}"

# Color codes
CYAN='\033[0;36m'
GRAY='\033[0;90m'
RESET='\033[0m'

printf '%b\n' "${CYAN}${dir}${RESET} ${GRAY}${model}${RESET}"
