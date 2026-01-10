#!/bin/bash
# Claude Code status line script
# Displays: profile, model, directory

input=$(cat)
model=$(echo "$input" | jq -r '.model.display_name // "unknown"')
dir=$(echo "$input" | jq -r '.workspace.current_dir // "."' | sed "s|^$HOME|~|" | sed 's|.*/||')

# Color codes
GREEN='\033[0;32m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
RESET='\033[0m'

# Profile indicator from CLAUDE_PROFILE env var (set by wrapper)
profile="${CLAUDE_PROFILE:-default}"

echo -e "${GREEN}[${profile}]${RESET} ${CYAN}${dir}${RESET} ${GRAY}${model}${RESET}"
