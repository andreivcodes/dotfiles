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
    # Codex shared configuration
    "$REPO_ROOT/dotfiles/codex/config.toml"
    "$REPO_ROOT/dotfiles/agents/AGENTS.md"
    # Claude Code shared configuration
    "$REPO_ROOT/dotfiles/claude/settings.json"
    "$REPO_ROOT/dotfiles/claude/mcp.json"
    "$REPO_ROOT/dotfiles/agents/AGENTS.md"
    "$REPO_ROOT/dotfiles/claude/statusline.sh"
    # OpenCode shared configuration
    "$REPO_ROOT/dotfiles/opencode/opencode.json"
    "$REPO_ROOT/dotfiles/agents/AGENTS.md"
)

TARGETS=(
    # Zed editor
    "$HOME/.config/zed"
    # Shell configuration
    "$HOME/.zshrc"
    # Codex shared configuration
    "$HOME/.codex/config.toml"
    "$HOME/.codex/AGENTS.md"
    # Claude Code shared configuration
    "$HOME/.claude/settings.json"
    "$HOME/.claude/mcp.json"
    "$HOME/.claude/CLAUDE.md"
    "$HOME/.claude/statusline.sh"
    # OpenCode shared configuration
    "$HOME/.config/opencode/opencode.json"
    "$HOME/.config/opencode/AGENTS.md"
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

# Sync agent skills directory so the repo remains the canonical source.
# Tool-specific skills directories are symlinked to this shared location below.
log_info "Syncing agent skills..."
if [ -L "$HOME/.agents/skills" ]; then
    rm -f "$HOME/.agents/skills"
fi
if [ -d "$REPO_ROOT/dotfiles/agents/skills" ]; then
    mkdir -p "$HOME/.agents/skills"
    rsync -a --delete "$REPO_ROOT/dotfiles/agents/skills/" "$HOME/.agents/skills/"
    log_success "Agent skills synced"
else
    log_warning "No agent skills source found; skipping sync"
fi

# Superpowers for Codex publishes skills by symlinking into ~/.agents/skills.
# Recreate that link after syncing repo-managed skills so it survives rsync --delete.
SUPERPOWERS_SKILLS_SOURCE="$HOME/.codex/superpowers/skills"
SUPERPOWERS_SKILLS_TARGET="$HOME/.agents/skills/superpowers"
if [ -d "$SUPERPOWERS_SKILLS_SOURCE" ]; then
    if [ -L "$SUPERPOWERS_SKILLS_TARGET" ] && [ "$(readlink "$SUPERPOWERS_SKILLS_TARGET")" = "$SUPERPOWERS_SKILLS_SOURCE" ]; then
        log_success "Superpowers skills already linked"
    else
        rm -rf "$SUPERPOWERS_SKILLS_TARGET" 2>/dev/null || true
        ln -sf "$SUPERPOWERS_SKILLS_SOURCE" "$SUPERPOWERS_SKILLS_TARGET"
        log_success "Linked Superpowers skills into shared skills directory"
    fi
else
    log_info "Superpowers for Codex not installed; skipping external skills link"
fi

if [ -d "$HOME/.agents/skills" ]; then
    log_info "Linking shared skills into tool configuration directories..."

    SKILL_TARGETS=(
        "$HOME/.codex/skills"
        "$HOME/.claude/skills"
        "$HOME/.config/opencode/skills"
    )

    SKILL_LABELS=(
        "Codex"
        "Claude Code"
        "OpenCode"
    )

    for i in "${!SKILL_TARGETS[@]}"; do
        skill_target="${SKILL_TARGETS[$i]}"
        skill_label="${SKILL_LABELS[$i]}"

        mkdir -p "$(dirname "$skill_target")"
        rm -rf "$skill_target" 2>/dev/null || true
        ln -sf "$HOME/.agents/skills" "$skill_target"
        log_success "Linked shared skills for $skill_label"
    done
else
    log_warning "Shared skills directory not available; skipping tool symlinks"
fi

log_success "Dotfiles setup completed successfully!"
log_info "Restart your terminal or run 'source ~/.zshrc' to load the new shell configuration."
