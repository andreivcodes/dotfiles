#!/bin/bash
# Claude Code status line script
# Displays: profile, model, directory, cost, context usage

input=$(cat)
model=$(echo "$input" | jq -r '.model.display_name // "unknown"')
dir=$(echo "$input" | jq -r '.workspace.current_dir // "."' | sed "s|^$HOME|~|" | sed 's|.*/||')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0' | xargs printf "%.4f")

# Calculate context usage percentage (input + output tokens vs context window)
# Context window is total capacity for both input and output combined
input_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
output_tokens=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
context_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')

# Total tokens used = input + output
total_tokens=$((input_tokens + output_tokens))

if [ "$context_size" -gt 0 ] 2>/dev/null; then
    usage_pct=$((total_tokens * 100 / context_size))
else
    usage_pct=0
fi

# Color codes
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
GRAY='\033[0;90m'
RESET='\033[0m'

# Color code the usage percentage based on level
if [ "$usage_pct" -ge 80 ]; then
    usage_color="$RED"
elif [ "$usage_pct" -ge 50 ]; then
    usage_color="$YELLOW"
else
    usage_color="$GREEN"
fi

# Profile indicator from CLAUDE_PROFILE env var (set by wrapper)
profile="${CLAUDE_PROFILE:-default}"

echo -e "${GREEN}[${profile}]${RESET} ${CYAN}${dir}${RESET} ${GRAY}${model}${RESET} ${YELLOW}\$${cost}${RESET} ${usage_color}${usage_pct}%${RESET}"
