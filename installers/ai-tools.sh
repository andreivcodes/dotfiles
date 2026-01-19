#!/bin/bash

set -euo pipefail

# Source utility functions
source "$(dirname "$0")/../lib/utils.sh"

log_info "Starting AI tools setup..."

# Ensure not running as sudo
check_not_sudo
require_macos

# ============================================================================
# OpenCode Installation (Native)
# ============================================================================
if command_exists opencode; then
    log_info "OpenCode is already installed"
    if [[ "${OPENCODE_UPDATE:-}" == "1" ]]; then
        log_info "Updating OpenCode via native installer..."
        update_args=(--no-modify-path)
        if [[ -n "${OPENCODE_VERSION:-}" ]]; then
            update_args+=(--version "$OPENCODE_VERSION")
        fi
        if curl -fsSL --max-time 60 https://opencode.ai/install | bash -s -- "${update_args[@]}"; then
            export PATH="$HOME/.opencode/bin:$PATH"
            log_success "OpenCode updated successfully"
        else
            log_warning "OpenCode update did not complete. You can update manually:"
            log_info "  curl -fsSL https://opencode.ai/install | bash"
        fi
    else
        # Check for updates
        if opencode version 2>/dev/null; then
            log_success "OpenCode verified"
        fi
    fi
else
    log_info "Installing OpenCode via native installer..."
    if curl -fsSL --max-time 60 https://opencode.ai/install | bash -s -- --no-modify-path; then
        # Reload path
        export PATH="$HOME/.opencode/bin:$PATH"
        log_success "OpenCode installed successfully"
    else
        log_warning "OpenCode installation did not complete. You can install manually:"
        log_info "  curl -fsSL https://opencode.ai/install | bash"
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
log_info "  - OpenCode: opencode -u <profile> then /connect"
log_info "  - Claude Code: claude -u <profile> then follow prompts"
