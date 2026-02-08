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
    # Codex CLI profiles
    "$REPO_ROOT/dotfiles/codex/personal/config.toml"
    "$REPO_ROOT/dotfiles/codex/personal/AGENTS.md"
    "$REPO_ROOT/dotfiles/codex/work/config.toml"
    "$REPO_ROOT/dotfiles/codex/work/AGENTS.md"
    # Claude Code profiles
    "$REPO_ROOT/dotfiles/claude/personal/mcp.json"
    "$REPO_ROOT/dotfiles/claude/personal/settings.json"
    "$REPO_ROOT/dotfiles/claude/personal/AGENTS.md"
    "$REPO_ROOT/dotfiles/claude/statusline.sh"
    "$REPO_ROOT/dotfiles/claude/work/mcp.json"
    "$REPO_ROOT/dotfiles/claude/work/settings.json"
    "$REPO_ROOT/dotfiles/claude/work/AGENTS.md"
    "$REPO_ROOT/dotfiles/claude/statusline.sh"
    # Note: Agent skills are synced via rsync below (not symlinked)
    # This avoids double-symlink issues with per-agent skill discovery
)

TARGETS=(
    # Zed editor
    "$HOME/.config/zed"
    # Shell configuration
    "$HOME/.zshrc"
    # Codex CLI profiles
    "$HOME/.codex-profiles/personal/config.toml"
    "$HOME/.codex-profiles/personal/AGENTS.md"
    "$HOME/.codex-profiles/work/config.toml"
    "$HOME/.codex-profiles/work/AGENTS.md"
    # Claude Code profiles
    "$HOME/.claude-profiles/personal/config/mcp.json"
    "$HOME/.claude-profiles/personal/config/settings.json"
    "$HOME/.claude-profiles/personal/config/AGENTS.md"
    "$HOME/.claude-profiles/personal/config/statusline.sh"
    "$HOME/.claude-profiles/work/config/mcp.json"
    "$HOME/.claude-profiles/work/config/settings.json"
    "$HOME/.claude-profiles/work/config/AGENTS.md"
    "$HOME/.claude-profiles/work/config/statusline.sh"
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

# Sync agent skills directory (rsync instead of symlink to avoid double-symlink issues)
# Claude Code bug #14836: skill discovery doesn't follow symlinks, so ~/.agents/skills
# must be a real directory. Per-agent symlinks (e.g., ~/.claude/skills/foo) are managed
# by the skills tool and will point here.
log_info "Syncing agent skills..."
if [ -L "$HOME/.agents/skills" ]; then
    # Remove existing symlink (this is the migration path)
    rm -f "$HOME/.agents/skills"
fi
if [ -d "$REPO_ROOT/dotfiles/agents/skills" ]; then
    mkdir -p "$HOME/.agents/skills"
    rsync -a --delete "$REPO_ROOT/dotfiles/agents/skills/" "$HOME/.agents/skills/"
    log_success "Agent skills synced"
else
    log_warning "No agent skills source found; skipping sync"
fi

# Create per-profile skills symlinks
# Claude Code with profiles looks for skills relative to CLAUDE_CONFIG_DIR
# Since npx skills installs to ~/.claude/skills/ but profiles use different paths,
# we create symlinks from each profile's expected location to the shared ~/.agents/skills/
log_info "Creating per-profile skills symlinks..."
for profile in personal work; do
    profile_config_skills="$HOME/.claude-profiles/$profile/config/skills"
    profile_root_skills="$HOME/.claude-profiles/$profile/skills"

    # Create symlink in config/ directory
    if [ ! -L "$profile_config_skills" ]; then
        rm -rf "$profile_config_skills" 2>/dev/null || true
        ln -sf "$HOME/.agents/skills" "$profile_config_skills"
        log_success "Created skills symlink for $profile profile (config)"
    fi

    # Create symlink at profile root (fallback)
    if [ ! -L "$profile_root_skills" ]; then
        rm -rf "$profile_root_skills" 2>/dev/null || true
        ln -sf "$HOME/.agents/skills" "$profile_root_skills"
        log_success "Created skills symlink for $profile profile (root)"
    fi
done

# Codex CLI profiles (if applicable)
for profile in personal work; do
    codex_skills="$HOME/.codex-profiles/$profile/skills"
    if [ ! -L "$codex_skills" ]; then
        rm -rf "$codex_skills" 2>/dev/null || true
        ln -sf "$HOME/.agents/skills" "$codex_skills"
        log_success "Created skills symlink for Codex $profile profile"
    fi
done

log_success "Dotfiles setup completed successfully!"
log_info "Restart your terminal or run 'source ~/.zshrc' to load the new shell configuration."
