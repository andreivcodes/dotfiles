#!/bin/bash

set -euo pipefail

# Source utility functions
source "$(dirname "$0")/../lib/utils.sh"

log_info "Starting development environment setup..."

# Ensure not running as sudo
check_not_sudo
require_macos

# Ensure shell environment is loaded
source "$HOME/.zprofile" 2>/dev/null || true

# Oh My Zsh setup
log_info "Setting up Oh My Zsh..."
if [ -d "$HOME/.oh-my-zsh" ]; then
    log_info "Oh My Zsh is already installed"
else
    log_info "Installing Oh My Zsh..."
    if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
        log_success "Oh My Zsh installed successfully"
    else
        log_error "Failed to install Oh My Zsh"
        exit 1
    fi
fi

# Install useful Oh My Zsh plugins
log_info "Installing Oh My Zsh plugins..."
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    log_info "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    log_success "zsh-autosuggestions installed"
else
    log_info "zsh-autosuggestions already installed"
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    log_info "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    log_success "zsh-syntax-highlighting installed"
else
    log_info "zsh-syntax-highlighting already installed"
fi

# Node.js and npm setup using NVM
log_info "Setting up Node.js environment..."
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    log_info "NVM is already installed. Setting up Node environment."
    source "$HOME/.nvm/nvm.sh" 2>/dev/null || true
    log_success "NVM environment loaded"
else
    log_info "NVM not found. Installing NVM..."
    if curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash; then
        source "$HOME/.nvm/nvm.sh" 2>/dev/null || true
        source "$HOME/.zprofile" 2>/dev/null || true
        log_success "NVM installed successfully"
    else
        log_error "Failed to install NVM"
        exit 1
    fi
fi

# Install and setup Node.js
show_progress "1" "4" "Installing latest Node.js"
if nvm install node; then
    log_success "Node.js installed successfully"
else
    log_error "Failed to install Node.js"
    exit 1
fi

show_progress "2" "4" "Setting Node.js as default"
if nvm use node; then
    log_success "Node.js set as default"
else
    log_warning "Could not set Node.js as default, but continuing..."
fi

# Install global packages
GLOBAL_PACKAGES=("pnpm" "npm-check-updates")
current=2

for package in "${GLOBAL_PACKAGES[@]}"; do
    current=$((current + 1))
    show_progress "$current" "4" "Installing $package globally"
    
    if npm install -g "$package"; then
        log_success "Successfully installed $package"
    else
        log_error "Failed to install $package"
    fi
done

# Bun setup
log_info "Setting up Bun..."
if command_exists bun; then
    log_info "Bun is already installed"
    bun --version
else
    log_info "Installing Bun..."
    if curl -fsSL https://bun.sh/install | bash; then
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
        log_success "Bun installed successfully"
    else
        log_error "Failed to install Bun"
        exit 1
    fi
fi

# Rust setup using rustup
log_info "Setting up Rust development environment..."
if command_exists rustup; then
    log_info "rustup is already installed. Ensuring Rust environment is configured."
    . "$HOME/.cargo/env" 2>/dev/null || true
    log_success "Rust environment loaded"
else
    log_info "rustup not found. Installing Rust..."
    if curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y; then
        . "$HOME/.cargo/env" 2>/dev/null || true
        log_success "Rust installed successfully"
    else
        log_error "Failed to install Rust"
        exit 1
    fi
fi

# Install Rust tools
RUST_TOOLS=(
    "cargo-autoinherit"
    "cargo-upgrades"
    "cargo-edit"
    "cargo-sort"
    "sea-orm-cli"
    "cargo-nextest"
)

log_info "Installing Rust development tools..."
total=${#RUST_TOOLS[@]}
current=0
failed_tools=()

for tool in "${RUST_TOOLS[@]}"; do
    current=$((current + 1))
    show_progress "$current" "$total" "Installing $tool"
    
    if cargo install "$tool"; then
        log_success "Successfully installed $tool"
    else
        log_error "Failed to install $tool"
        failed_tools+=("$tool")
    fi
done

# Summary
if [ ${#failed_tools[@]} -eq 0 ]; then
    log_success "Development environment setup completed successfully!"
    log_info "Node.js, pnpm, and Rust development tools are now configured"
else
    log_warning "Development environment setup completed with some failures:"
    for tool in "${failed_tools[@]}"; do
        log_error "  Failed: $tool"
    done
fi
