#!/bin/bash
# Claude Code status line script
# Displays: directory, model

input=$(cat)
model=$(echo "$input" | jq -r '.model.display_name // "unknown"')
dir=$(echo "$input" | jq -r '.workspace.current_dir // "."' | sed "s|^$HOME|~|" | sed 's|.*/||')

# Color codes
CYAN='\033[0;36m'
GRAY='\033[0;90m'
RESET='\033[0m'

echo -e "${CYAN}${dir}${RESET} ${GRAY}${model}${RESET}"
