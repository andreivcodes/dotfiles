#!/bin/bash

set -euo pipefail

# Source utility functions
source "$(dirname "$0")/../lib/utils.sh"

log_info "Starting Homebrew setup..."

# Ensure not running as sudo
check_not_sudo
require_macos

# Check if Homebrew is already installed
if command_exists brew; then
    log_info "Homebrew is already installed. Updating and upgrading."
    if brew update && brew upgrade; then
        log_success "Homebrew updated and upgraded successfully"
    else
        log_warning "Homebrew update/upgrade had some issues, but continuing..."
    fi
    # Turn off Homebrew analytics to reduce noise
    brew analytics off >/dev/null 2>&1 || true
else
    log_info "Homebrew not found. Installing..."
    if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        # Detect brew binary location (Apple Silicon vs Intel)
        if [ -x "/opt/homebrew/bin/brew" ]; then
            BREW_BIN="/opt/homebrew/bin/brew"
        elif [ -x "/usr/local/bin/brew" ]; then
            BREW_BIN="/usr/local/bin/brew"
        else
            log_error "Homebrew installed but brew binary not found in standard locations"
            exit 1
        fi
        # Persist and load shellenv
        echo "eval \"\$($BREW_BIN shellenv)\"" >> "$HOME/.zprofile"
        eval "$($BREW_BIN shellenv)"
        # Turn off analytics on fresh installs as well
        brew analytics off >/dev/null 2>&1 || true
        log_success "Homebrew installed successfully"
    else
        log_error "Failed to install Homebrew"
        exit 1
    fi
fi

# Ensure shell environment is loaded for brew
source "$HOME/.zprofile" 2>/dev/null || true

# Recommend Command Line Tools if missing
if ! xcode-select -p &>/dev/null; then
    log_warning "Xcode Command Line Tools not detected. Some formulae may require them. Run: xcode-select --install"
fi

# Install via Brewfile
REPO_ROOT="$(cd "$(dirname "$0")/.." >/dev/null 2>&1 && pwd)"
BREWFILE_PATH="$REPO_ROOT/Brewfile"

if [ ! -f "$BREWFILE_PATH" ]; then
    log_error "Brewfile not found at $BREWFILE_PATH"
    exit 1
fi

log_info "Installing packages and apps from Brewfile..."
if brew bundle --file="$BREWFILE_PATH"; then
    log_success "Brew bundle completed successfully"
else
    log_warning "Brew bundle encountered errors (some items may be unavailable). Continuing..."
fi

log_info "$(brew list --formula | wc -l | xargs) formulas and $(brew list --cask | wc -l | xargs) casks are now installed"

# Claude Code (optional)
if command_exists claude; then
    log_info "Claude Code already installed, skipping"
else
    if [ "${INSTALL_CLAUDE:-0}" = "1" ]; then
        log_info "Installing Claude Code (INSTALL_CLAUDE=1)..."
        if curl -fsSL --max-time 20 https://claude.ai/install.sh | bash; then
            log_success "Claude Code installed successfully"
        else
            log_warning "Claude Code installation did not complete. You can install manually: curl -fsSL https://claude.ai/install.sh | bash"
        fi
    else
        log_info "Skipping Claude Code auto-install. To install now: INSTALL_CLAUDE=1 bash installers/brew.sh"
        log_info "Manual install command: curl -fsSL https://claude.ai/install.sh | bash"
    fi
fi
