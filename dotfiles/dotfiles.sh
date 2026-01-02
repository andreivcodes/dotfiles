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
    "$REPO_ROOT/dotfiles/zed"
    "$REPO_ROOT/dotfiles/.zshrc"
    "$REPO_ROOT/dotfiles/opencode/personal/opencode.json"
    "$REPO_ROOT/dotfiles/opencode/work/opencode.json"
)

TARGETS=(
    "$HOME/.config/zed"
    "$HOME/.zshrc"
    "$HOME/.opencode-profiles/personal/config/opencode.json"
    "$HOME/.opencode-profiles/work/config/opencode.json"
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
