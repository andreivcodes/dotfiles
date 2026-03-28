#!/bin/bash

set -euo pipefail

# Source utility functions
source "$(dirname "$0")/../lib/utils.sh"

log_info "Starting AI tools setup..."

# Ensure not running as sudo
check_not_sudo
require_macos

# Ensure shell environment is loaded for npm/npx installed via NVM
source "$HOME/.zprofile" 2>/dev/null || true

ensure_npm_available() {
    if command_exists npm; then
        return 0
    fi

    if [ -s "$HOME/.nvm/nvm.sh" ]; then
        source "$HOME/.nvm/nvm.sh" 2>/dev/null || true
    fi

    command_exists npm
}

ensure_claude_marketplace() {
    local marketplace_name="claude-plugins-official"
    local marketplace_source="anthropics/claude-plugins-official"

    if claude plugins marketplace list 2>/dev/null | grep -Fq "$marketplace_name"; then
        log_info "Claude Code marketplace $marketplace_name already configured"
        return 0
    fi

    log_info "Adding Claude Code marketplace $marketplace_name..."
    if claude plugins marketplace add "$marketplace_source"; then
        log_success "Claude Code marketplace $marketplace_name added"
        return 0
    fi

    log_warning "Failed to add Claude Code marketplace $marketplace_name. Install manually:"
    log_info "  claude plugins marketplace add $marketplace_source"
    return 1
}

ensure_claude_plugin() {
    local plugin=$1

    if claude plugins list 2>/dev/null | grep -Fq "$plugin"; then
        log_info "Claude Code plugin $plugin already installed"
        return 0
    fi

    log_info "Installing Claude Code plugin $plugin..."
    if claude plugins install --scope user "$plugin"; then
        log_success "Claude Code plugin $plugin installed"
        return 0
    fi

    log_warning "Failed to install Claude Code plugin $plugin. Install manually:"
    log_info "  claude plugins install --scope user $plugin"
    return 1
}

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
# Claude Code Plugins
# ============================================================================
CLAUDE_PLUGINS=(
    "rust-analyzer-lsp@claude-plugins-official"
    "typescript-lsp@claude-plugins-official"
    "code-review@claude-plugins-official"
    "skill-creator@claude-plugins-official"
    "superpowers@claude-plugins-official"
)

if command_exists claude; then
    log_info "Ensuring Claude Code marketplace and plugins are installed..."
    if ensure_claude_marketplace; then
        for plugin in "${CLAUDE_PLUGINS[@]}"; do
            ensure_claude_plugin "$plugin"
        done
    fi
fi

# ============================================================================
# OpenCode Installation (Homebrew formula)
# ============================================================================
if command_exists opencode; then
    log_info "OpenCode is already installed"
    if opencode --version 2>/dev/null; then
        log_success "OpenCode verified"
    fi
else
    log_info "Installing OpenCode via Homebrew..."
    if brew install anomalyco/tap/opencode; then
        log_success "OpenCode installed successfully"
    else
        log_warning "OpenCode installation failed. Install manually:"
        log_info "  brew install anomalyco/tap/opencode"
    fi
fi

# ============================================================================
# Railway CLI Installation
# ============================================================================
if command_exists railway; then
    log_info "Railway CLI is already installed"
    if railway --version 2>/dev/null; then
        log_success "Railway CLI verified"
    fi
else
    log_info "Installing Railway CLI via Homebrew..."
    if brew install railway; then
        log_success "Railway CLI installed successfully"
    else
        log_warning "Railway CLI installation failed. Install manually:"
        log_info "  brew install railway"
    fi
fi

# ============================================================================
# Vercel CLI Installation
# ============================================================================
if command_exists vercel; then
    log_info "Vercel CLI is already installed"
    if vercel --version 2>/dev/null; then
        log_success "Vercel CLI verified"
    fi
else
    log_info "Installing Vercel CLI via npm..."
    if ensure_npm_available && npm install -g vercel@latest; then
        log_success "Vercel CLI installed successfully"
    else
        log_warning "Vercel CLI installation failed. Install manually:"
        log_info "  npm i -g vercel@latest"
    fi
fi

# ============================================================================
# Superpowers for Codex
# ============================================================================
SUPERPOWERS_DIR="$HOME/.codex/superpowers"
SUPERPOWERS_REPO_URL="https://github.com/obra/superpowers.git"

log_info "Setting up Superpowers for Codex..."
if ! command_exists git; then
    log_warning "Git is required to install Superpowers for Codex; skipping"
elif [ -d "$SUPERPOWERS_DIR/.git" ]; then
    if git -C "$SUPERPOWERS_DIR" pull --ff-only; then
        log_success "Superpowers updated in $SUPERPOWERS_DIR"
    else
        log_warning "Superpowers update failed. Update manually:"
        log_info "  git -C $SUPERPOWERS_DIR pull --ff-only"
    fi
elif [ -e "$SUPERPOWERS_DIR" ]; then
    log_warning "Existing path is not a git repository: $SUPERPOWERS_DIR"
    log_info "  Remove or rename it, then run:"
    log_info "  git clone $SUPERPOWERS_REPO_URL $SUPERPOWERS_DIR"
else
    mkdir -p "$(dirname "$SUPERPOWERS_DIR")"
    if git clone "$SUPERPOWERS_REPO_URL" "$SUPERPOWERS_DIR"; then
        log_success "Superpowers cloned to $SUPERPOWERS_DIR"
    else
        log_warning "Superpowers clone failed. Install manually:"
        log_info "  git clone $SUPERPOWERS_REPO_URL $SUPERPOWERS_DIR"
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
    if ensure_npm_available && npm install -g agent-browser; then
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
log_info "  - Codex: codex login"
log_info "  - Claude Code: claude auth login"
log_info "  - OpenCode: opencode auth login"
log_info "  - Railway CLI: railway login"
log_info "  - Vercel CLI: vercel login"
log_info "Restart Codex, Claude Code, and OpenCode after dotfiles sync so skills and plugins reload."
