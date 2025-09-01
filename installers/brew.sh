#!/bin/bash

set -euo pipefail

# Source utility functions
source "$(dirname "$0")/../lib/utils.sh"

log_info "Starting Homebrew setup..."

# Ensure not running as sudo
check_not_sudo

# Check if Homebrew is already installed
if command_exists brew; then
    log_info "Homebrew is already installed. Updating and upgrading."
    if brew update && brew upgrade; then
        log_success "Homebrew updated and upgraded successfully"
    else
        log_warning "Homebrew update/upgrade had some issues, but continuing..."
    fi
else
    log_info "Homebrew not found. Installing..."
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        echo 'eval $(/opt/homebrew/bin/brew shellenv)' >> "$HOME/.zprofile"
        source "$HOME/.zprofile"
        log_success "Homebrew installed successfully"
    else
        log_error "Failed to install Homebrew"
        exit 1
    fi
fi

# Ensure shell environment is loaded for brew
source "$HOME/.zprofile" 2>/dev/null || true

# Define packages to install
FORMULAS=(
    "wget"
    "volta"
    "nixpacks" 
    "act"
    "ansible"
    "asimov"
    "mas"
    "displayplacer"
)

CASKS=(
    "discord"
    "slack"
    "whatsapp"
    "telegram"
    "zed"
    "github"
    "docker"
    "dbeaver-community"
    "brave-browser"
    "wifiman"
    "1password"
    "1password-cli"
    "macs-fan-control"
    "tailscale"
    "mullvadvpn"
    "balenaetcher"
    "libreoffice"
    "signal"
    "topnotch"
    "cleanshot"
    "rectangle"
)

# Install formula packages
log_info "Installing essential brew packages..."
total_formulas=${#FORMULAS[@]}
current=0

for formula in "${FORMULAS[@]}"; do
    current=$((current + 1))
    show_progress $current $total_formulas "Installing $formula"
    
    if brew list "$formula" &>/dev/null; then
        log_info "$formula is already installed, skipping"
    elif brew install "$formula"; then
        log_success "Successfully installed $formula"
    else
        log_error "Failed to install $formula"
        # Continue with other packages instead of exiting
    fi
done

# Ensure shell environment is loaded again after volta install
source "$HOME/.zprofile" 2>/dev/null || true
sleep 1

log_success "Essential brew packages installation completed"

# Install cask applications
log_info "Installing applications via brew cask..."
total_casks=${#CASKS[@]}
current=0

for cask in "${CASKS[@]}"; do
    current=$((current + 1))
    show_progress $current $total_casks "Installing $cask"
    
    if brew list --cask "$cask" &>/dev/null; then
        log_info "$cask is already installed, skipping"
    elif brew install --cask "$cask"; then
        log_success "Successfully installed $cask"
    else
        log_error "Failed to install $cask"
        # Continue with other apps instead of exiting
    fi
done

sleep 1

log_success "Brew setup completed successfully!"
log_info "$(brew list --formula | wc -l | xargs) formulas and $(brew list --cask | wc -l | xargs) casks are now installed"

# Install Mac App Store applications
if command_exists mas; then
    log_info "Installing Mac App Store applications..."
    
    # Amphetamine - Keep your Mac awake
    if mas list | grep -q "937984704"; then
        log_info "Amphetamine is already installed, skipping"
    elif mas install 937984704; then
        log_success "Successfully installed Amphetamine"
    else
        log_error "Failed to install Amphetamine"
        log_info "You may need to sign in to the Mac App Store first with: mas signin"
    fi
else
    log_warning "mas not available, skipping Mac App Store applications"
fi

# Install Claude Code
log_info "Installing Claude Code..."
if curl -fsSL https://claude.ai/install.sh | bash; then
    log_success "Claude Code installed successfully"
else
    log_error "Failed to install Claude Code"
fi
