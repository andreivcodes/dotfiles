#!/bin/bash

set -euo pipefail

# Claude Code status line script
# Mirrors robbyrussell Oh My Zsh theme:
# Displays: directory (cyan), git branch (blue/red), model (gray)

if ! command -v jq >/dev/null 2>&1; then
    printf '%s\n' "${PWD##*/}"
    exit 0
fi

input=$(cat)
model=$(jq -r '.model.display_name // "unknown"' <<<"$input")
dir=$(jq -r '.workspace.current_dir // "."' <<<"$input")
dir="${dir/#$HOME/~}"
dir_basename="${dir##*/}"

# Context window and rate limit usage
ctx_pct=$(jq -r '.context_window.used_percentage // empty' <<<"$input")
rate_5h=$(jq -r '.rate_limits.five_hour.used_percentage // empty' <<<"$input")
rate_7d=$(jq -r '.rate_limits.seven_day.used_percentage // empty' <<<"$input")

# Color codes
CYAN='\033[0;36m'
BOLD_BLUE='\033[1;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
GRAY='\033[0;90m'
RESET='\033[0m'

# Color a percentage: green <50, yellow 50-79, red 80+
color_pct() {
    local val=$1
    local int=${val%.*}
    if [ "$int" -ge 80 ]; then
        printf '%b' "${RED}${int}%${RESET}"
    elif [ "$int" -ge 50 ]; then
        printf '%b' "${YELLOW}${int}%${RESET}"
    else
        printf '%b' "${GREEN}${int}%${RESET}"
    fi
}

# Git branch info (mirrors robbyrussell git_prompt_info)
git_info=""
if command -v git >/dev/null 2>&1; then
    branch=$(git -C "$dir" branch --show-current 2>/dev/null || true)
    if [ -n "$branch" ]; then
        # Check for dirty state (untracked, modified, or staged files)
        if git -C "$dir" --no-optional-locks status --porcelain 2>/dev/null | grep -q .; then
            dirty=" ${YELLOW}✗${RESET}"
        else
            dirty=""
        fi
        git_info=" ${BOLD_BLUE}git:(${RED}${branch}${BOLD_BLUE})${dirty}${RESET}"
    fi
fi

# Build usage indicators
usage=""
if [ -n "$ctx_pct" ]; then
    usage=" ${GRAY}ctx:${RESET}$(color_pct "$ctx_pct")"
fi
if [ -n "$rate_5h" ]; then
    usage="${usage} ${GRAY}5h:${RESET}$(color_pct "$rate_5h")"
fi
if [ -n "$rate_7d" ]; then
    usage="${usage} ${GRAY}7d:${RESET}$(color_pct "$rate_7d")"
fi

printf '%b\n' "${CYAN}${dir_basename}${RESET}${git_info} ${GRAY}${model}${RESET}${usage}"
