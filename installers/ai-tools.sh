#!/bin/bash

set -euo pipefail

# Source utility functions
source "$(dirname "$0")/../lib/utils.sh"

log_info "Starting AI tools setup..."

# Ensure not running as sudo
check_not_sudo
require_macos

# ============================================================================
# Codex CLI Installation (Homebrew cask)
# ============================================================================
if command_exists codex; then
    log_info "Codex CLI is already installed"
    if codex --version 2>/dev/null; then
        log_success "Codex CLI verified"
    fi
else
    log_info "Installing Codex CLI via Homebrew..."
    if brew install --cask codex; then
        log_success "Codex CLI installed successfully"
    else
        log_warning "Codex CLI installation failed. Install manually:"
        log_info "  brew install --cask codex"
    fi
fi

# ============================================================================
# Claude Code Installation (Native)
# ============================================================================
if command_exists claude; then
    log_info "Claude Code is already installed"
    # Check version
    if claude --version 2>/dev/null; then
        log_success "Claude Code verified"
    fi
else
    log_info "Installing Claude Code via native installer..."
    if curl -fsSL --max-time 60 https://claude.ai/install.sh | bash; then
        # Reload path
        export PATH="$HOME/.claude/bin:$PATH"
        log_success "Claude Code installed successfully"
    else
        log_warning "Claude Code installation did not complete. You can install manually:"
        log_info "  curl -fsSL https://claude.ai/install.sh | bash"
    fi
fi

# ============================================================================
# Agent Browser Installation (Vercel Labs)
# ============================================================================
log_info "Setting up Agent Browser..."
if command_exists agent-browser; then
    log_info "Agent Browser is already installed"
    if agent-browser --version 2>/dev/null; then
        log_success "Agent Browser verified"
    fi
else
    log_info "Installing Agent Browser globally..."
    if npm install -g agent-browser; then
        log_success "Agent Browser installed successfully"
    else
        log_warning "Agent Browser installation failed. You can install manually:"
        log_info "  npm install -g agent-browser"
    fi
fi

# Install Chromium for Agent Browser
log_info "Ensuring Chromium is installed for Agent Browser..."
if agent-browser install 2>/dev/null; then
    log_success "Chromium installed/verified for Agent Browser"
else
    log_warning "Chromium installation skipped or failed. You can install manually:"
    log_info "  agent-browser install"
fi

log_success "AI tools setup completed!"
log_info "Remember to authenticate with each tool:"
log_info "  - Codex: codex -u <profile>"
log_info "  - Claude Code: claude -u <profile> then follow prompts"
