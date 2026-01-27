#!/bin/bash

set -euo pipefail

# Source utility functions
source "$(dirname "$0")/../lib/utils.sh"

log_info "Setting up dotfiles symlinks..."

# Ensure not running as sudo
check_not_sudo
require_macos

# Create config directory if it doesn't exist
mkdir -p "$HOME/.config"

# Resolve repo root regardless of current working directory
REPO_ROOT="$(cd "$(dirname "$0")/.." >/dev/null 2>&1 && pwd)"

# Configuration mappings: source -> target (using parallel arrays for bash 3.2 compatibility)
SOURCES=(
    # Zed editor
    "$REPO_ROOT/dotfiles/zed"
    # Shell configuration
    "$REPO_ROOT/dotfiles/.zshrc"
    # OpenCode profiles
    "$REPO_ROOT/dotfiles/opencode/personal/opencode.json"
    "$REPO_ROOT/dotfiles/opencode/personal/AGENTS.md"
    "$REPO_ROOT/dotfiles/opencode/work/opencode.json"
    "$REPO_ROOT/dotfiles/opencode/work/AGENTS.md"
    # Claude Code profiles
    "$REPO_ROOT/dotfiles/claude/personal/mcp.json"
    "$REPO_ROOT/dotfiles/claude/personal/settings.json"
    "$REPO_ROOT/dotfiles/claude/personal/AGENTS.md"
    "$REPO_ROOT/dotfiles/claude/statusline.sh"
    "$REPO_ROOT/dotfiles/claude/work/mcp.json"
    "$REPO_ROOT/dotfiles/claude/work/settings.json"
    "$REPO_ROOT/dotfiles/claude/work/AGENTS.md"
    "$REPO_ROOT/dotfiles/claude/statusline.sh"
    # Shared agent skills (source of truth: dotfiles/agents/skills)
    "$REPO_ROOT/dotfiles/agents/skills"
    "$REPO_ROOT/dotfiles/agents/skills"
    "$REPO_ROOT/dotfiles/agents/skills"
    "$REPO_ROOT/dotfiles/agents/skills"
    "$REPO_ROOT/dotfiles/agents/skills"
    "$REPO_ROOT/dotfiles/agents/skills"
)

TARGETS=(
    # Zed editor
    "$HOME/.config/zed"
    # Shell configuration
    "$HOME/.zshrc"
    # OpenCode profiles
    "$HOME/.opencode-profiles/personal/config/opencode.json"
    "$HOME/.opencode-profiles/personal/config/AGENTS.md"
    "$HOME/.opencode-profiles/work/config/opencode.json"
    "$HOME/.opencode-profiles/work/config/AGENTS.md"
    # Claude Code profiles
    "$HOME/.claude-profiles/personal/config/mcp.json"
    "$HOME/.claude-profiles/personal/config/settings.json"
    "$HOME/.claude-profiles/personal/config/AGENTS.md"
    "$HOME/.claude-profiles/personal/config/statusline.sh"
    "$HOME/.claude-profiles/work/config/mcp.json"
    "$HOME/.claude-profiles/work/config/settings.json"
    "$HOME/.claude-profiles/work/config/AGENTS.md"
    "$HOME/.claude-profiles/work/config/statusline.sh"
    # Shared agent skills (all point to dotfiles/agents/skills)
    "$HOME/.agents/skills"
    "$HOME/.claude/skills"
    "$HOME/.opencode/skills"
    "$HOME/.config/opencode/skill"
    "$HOME/.claude-profiles/personal/config/skills"
    "$HOME/.claude-profiles/work/config/skills"
)

total=${#SOURCES[@]}

for i in "${!SOURCES[@]}"; do
    source="${SOURCES[$i]}"
    target="${TARGETS[$i]}"
    current=$((i + 1))
    
    # Ensure parent directory exists for the target
    mkdir -p "$(dirname "$target")"
    
    config_name=$(basename "$source")
    show_progress "$current" "$total" "Setting up $config_name configuration"
    
    if safe_symlink "$source" "$target"; then
        log_success "Successfully configured $config_name"
    else
        log_error "Failed to configure $config_name"
        exit 1
    fi
done

log_success "Dotfiles setup completed successfully!"
log_info "Restart your terminal or run 'source ~/.zshrc' to load the new shell configuration."
