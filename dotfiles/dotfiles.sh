#!/bin/bash

set -euo pipefail

# Source utility functions
source "$(dirname "$0")/../lib/utils.sh"

log_info "Setting up dotfiles symlinks..."

# Ensure not running as sudo
check_not_sudo

# Create config directory if it doesn't exist
mkdir -p "$HOME/.config"

# Configuration mappings: source -> target
declare -A CONFIGS=(
    ["$PWD/dotfiles/zed"]="$HOME/.config/zed"
    ["$PWD/dotfiles/.zshrc"]="$HOME/.zshrc"
)

total=${#CONFIGS[@]}
current=0

for source in "${!CONFIGS[@]}"; do
    target="${CONFIGS[$source]}"
    current=$((current + 1))
    
    config_name=$(basename "$source")
    show_progress $current $total "Setting up $config_name configuration"
    
    if safe_symlink "$source" "$target"; then
        log_success "Successfully configured $config_name"
    else
        log_error "Failed to configure $config_name"
        exit 1
    fi
done

log_success "Dotfiles setup completed successfully!"
log_info "Restart your terminal or run 'source ~/.zshrc' to load the new shell configuration."