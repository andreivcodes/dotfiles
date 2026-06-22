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
    # Package manager defaults
    "$REPO_ROOT/dotfiles/.npmrc"
    "$REPO_ROOT/dotfiles/pnpm/rc"
    "$REPO_ROOT/dotfiles/.bunfig.toml"
    "$REPO_ROOT/dotfiles/.yarnrc.yml"
    # Asimeow configuration
    "$REPO_ROOT/dotfiles/asimeow/config.yaml"
    # Codex shared configuration
    "$REPO_ROOT/dotfiles/codex/config.toml"
    "$REPO_ROOT/dotfiles/agents/AGENTS.md"
    # Pi shared configuration
    "$REPO_ROOT/dotfiles/pi/mcp.json"
    "$REPO_ROOT/dotfiles/pi/models.json"
    "$REPO_ROOT/dotfiles/agents/AGENTS.md"
    "$REPO_ROOT/dotfiles/pi/pi-acp-zed.sh"
    # Claude Code shared configuration
    "$REPO_ROOT/dotfiles/claude/settings.json"
    "$REPO_ROOT/dotfiles/claude/mcp.json"
    "$REPO_ROOT/dotfiles/claude/desktop-mcp.json"
    "$REPO_ROOT/dotfiles/claude/CLAUDE.md"
    "$REPO_ROOT/dotfiles/agents/AGENTS.md"
    "$REPO_ROOT/dotfiles/claude/statusline.sh"
    "$REPO_ROOT/dotfiles/claude/claude-zed.sh"
    "$REPO_ROOT/dotfiles/claude/mcp-env-run.sh"
)

TARGETS=(
    # Zed editor
    "$HOME/.config/zed"
    # Shell configuration
    "$HOME/.zshrc"
    # Package manager defaults
    "$HOME/.npmrc"
    "$HOME/.config/pnpm/rc"
    "$HOME/.bunfig.toml"
    "$HOME/.yarnrc.yml"
    # Asimeow configuration
    "$HOME/.config/asimeow/config.yaml"
    # Codex shared configuration
    "$HOME/.codex/config.toml"
    "$HOME/.codex/AGENTS.md"
    # Pi shared configuration
    "$HOME/.pi/agent/mcp.json"
    "$HOME/.pi/agent/models.json"
    "$HOME/.pi/agent/AGENTS.md"
    "$HOME/.pi/agent/pi-acp-zed.sh"
    # Claude Code shared configuration
    "$HOME/.claude/settings.json"
    "$HOME/.claude/mcp.json"
    "$HOME/.claude/desktop-mcp.json"
    "$HOME/.claude/CLAUDE.md"
    "$HOME/.claude/AGENTS.md"
    "$HOME/.claude/statusline.sh"
    "$HOME/.claude/claude-zed.sh"
    "$HOME/.claude/mcp-env-run.sh"
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

merge_claude_desktop_mcp_config() {
    local desktop_config_dir="$HOME/Library/Application Support/Claude"
    local desktop_config="$desktop_config_dir/claude_desktop_config.json"
    local desktop_mcp_source="$HOME/.claude/desktop-mcp.json"
    local temp_file=""
    local backup_file=""

    [ -f "$desktop_mcp_source" ] || return 0

    if ! command_exists jq; then
        log_warning "jq is unavailable; skipping Claude Desktop MCP merge"
        return 0
    fi

    mkdir -p "$desktop_config_dir"

    if [ ! -f "$desktop_config" ]; then
        printf '{\n  "mcpServers": {}\n}\n' > "$desktop_config"
        chmod 600 "$desktop_config"
    fi

    if ! jq empty "$desktop_config" >/dev/null 2>&1; then
        log_warning "Claude Desktop config is not valid JSON; skipping MCP merge: $desktop_config"
        return 0
    fi

    if ! jq empty "$desktop_mcp_source" >/dev/null 2>&1; then
        log_warning "Claude Desktop MCP source is not valid JSON; skipping MCP merge: $desktop_mcp_source"
        return 0
    fi

    temp_file="$(mktemp "${TMPDIR:-/tmp}/claude-desktop-mcp.XXXXXX")"
    jq -s '
        .[0] as $current
        | .[1] as $managed
        | ($managed.mcpServers // {}) as $managed_servers
        | ($managed_servers | keys) as $managed_names
        | (($managed_names + ["railway"]) | unique) as $removed_managed_names
        | $current
        | .mcpServers = (
            ((.mcpServers // {})
            | del(.opencode, .OpenCode, .openCode, .open_code)
            | with_entries(select(.key as $name | ($removed_managed_names | index($name) | not))))
            + $managed_servers
        )
    ' \
        "$desktop_config" "$desktop_mcp_source" > "$temp_file"

    if cmp -s "$desktop_config" "$temp_file"; then
        rm -f "$temp_file"
        log_success "Claude Desktop MCP servers already configured"
        return 0
    fi

    backup_file="$HOME/.claude/backups/claude_desktop_config.$(date +%Y%m%d_%H%M%S).json"
    mkdir -p "$(dirname "$backup_file")"
    cp "$desktop_config" "$backup_file"
    mv "$temp_file" "$desktop_config"
    chmod 600 "$desktop_config"
    log_success "Merged Claude Desktop MCP servers"
    log_info "Backed up previous Claude Desktop config: $backup_file"
}

merge_claude_desktop_mcp_config

SHARED_SKILLS_DIR="$HOME/.agents/skills"
REPO_SKILLS_DIR="$REPO_ROOT/dotfiles/agents/skills"

cleanup_removed_repo_skill_links() {
    local skill_path=""
    local link_target=""

    [ -d "$SHARED_SKILLS_DIR" ] || return 0

    for skill_path in "$SHARED_SKILLS_DIR"/*; do
        [ -L "$skill_path" ] || continue

        link_target="$(readlink "$skill_path")"
        case "$link_target" in
            "$REPO_SKILLS_DIR"/*)
                if [ ! -e "$link_target" ]; then
                    rm -f "$skill_path"
                    log_info "Removed stale repo-managed skill link: $(basename "$skill_path")"
                fi
                ;;
        esac
    done
}

link_repo_skill() {
    local source_skill=$1
    local skill_name
    local target_skill

    skill_name="$(basename "$source_skill")"
    target_skill="$SHARED_SKILLS_DIR/$skill_name"

    if [ -L "$target_skill" ] && [ "$(readlink "$target_skill")" = "$source_skill" ]; then
        log_success "Repo skill already linked: $skill_name"
        return 0
    fi

    # Migrate legacy repo-managed directory copies from the old rsync-based
    # layout into symlinks so they can coexist with skills.sh symlink installs.
    if [ -d "$target_skill" ] && diff -qr "$source_skill" "$target_skill" >/dev/null 2>&1; then
        rm -rf "$target_skill"
        ln -s "$source_skill" "$target_skill"
        log_success "Migrated repo skill to symlink: $skill_name"
        return 0
    fi

    if [ -e "$target_skill" ] || [ -L "$target_skill" ]; then
        log_warning "Skipping repo skill $skill_name because $target_skill is already managed externally"
        return 0
    fi

    ln -s "$source_skill" "$target_skill"
    log_success "Linked repo skill: $skill_name"
}

# Link repo-managed agent skills into the shared skills directory without
# disturbing externally managed symlink installs from tools like skills.sh.
log_info "Syncing shared agent skills..."
mkdir -p "$HOME/.agents"

if [ -L "$SHARED_SKILLS_DIR" ] && [ ! -d "$SHARED_SKILLS_DIR" ]; then
    rm -f "$SHARED_SKILLS_DIR"
fi
mkdir -p "$SHARED_SKILLS_DIR"

if [ -d "$REPO_SKILLS_DIR" ]; then
    cleanup_removed_repo_skill_links

    for source_skill in "$REPO_SKILLS_DIR"/*; do
        [ -d "$source_skill" ] || continue
        link_repo_skill "$source_skill"
    done
else
    log_warning "No agent skills source found; skipping repo skill sync"
fi

if [ -d "$HOME/.agents/skills" ]; then
    log_info "Linking shared skills into tool configuration directories..."

    SKILL_TARGETS=(
        "$HOME/.codex/skills"
        "$HOME/.claude/skills"
    )

    SKILL_LABELS=(
        "Codex"
        "Claude Code"
    )

    for i in "${!SKILL_TARGETS[@]}"; do
        skill_target="${SKILL_TARGETS[$i]}"
        skill_label="${SKILL_LABELS[$i]}"

        mkdir -p "$(dirname "$skill_target")"
        if safe_symlink "$HOME/.agents/skills" "$skill_target"; then
            log_success "Linked shared skills for $skill_label"
        else
            log_error "Failed to link shared skills for $skill_label"
            exit 1
        fi
    done
else
    log_warning "Shared skills directory not available; skipping tool symlinks"
fi

# Pi auto-discovers ~/.agents/skills directly, so it does not need a tool-
# specific skills symlink.

log_success "Dotfiles setup completed successfully!"
log_info "Restart your terminal or run 'source ~/.zshrc' to load the new shell configuration."
