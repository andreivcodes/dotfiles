#!/bin/bash

set -euo pipefail

# Source utility functions
source "$(dirname "$0")/../lib/utils.sh"

log_info "Starting AI tools setup..."

# Ensure not running as sudo
check_not_sudo
require_macos

REPO_ROOT="$(cd "$(dirname "$0")/.." >/dev/null 2>&1 && pwd)"

# Ensure shell environment is loaded for npm/npx installed via NVM
# shellcheck source=/dev/null
source "$HOME/.zprofile" 2>/dev/null || true
# Load API keys persisted by mcp-env.sh for commands that validate or launch
# MCP servers during setup. Repo-managed configs keep ${VAR} placeholders.
# shellcheck source=/dev/null
source "$HOME/.zshrc.local" 2>/dev/null || true

ensure_npm_available() {
    if [ -s "$HOME/.nvm/nvm.sh" ]; then
        # shellcheck source=/dev/null
        source "$HOME/.nvm/nvm.sh" 2>/dev/null || true
        nvm use --silent default >/dev/null 2>&1 || true
    fi

    command_exists npm
}

npm_global_prefix() {
    npm prefix -g 2>/dev/null || true
}

resolve_npm_install_spec() {
    local npm_cmd=$1
    local install_spec=$2
    local package_ref=""
    local latest_version=""

    case "$install_spec" in
        *@latest)
            package_ref="${install_spec%@latest}"
            latest_version="$("$npm_cmd" view "$package_ref" version 2>/dev/null || true)"
            if [ -n "$latest_version" ]; then
                printf '%s@%s\n' "$package_ref" "$latest_version"
                return 0
            fi
            ;;
    esac

    printf '%s\n' "$install_spec"
}

nvm_default_npm_bin() {
    local nvm_version=""
    local npm_bin=""

    [ -s "$HOME/.nvm/nvm.sh" ] || return 0

    # shellcheck source=/dev/null
    source "$HOME/.nvm/nvm.sh" 2>/dev/null || true
    nvm_version="$(nvm version default 2>/dev/null || true)"
    case "$nvm_version" in
        ""|"N/A"|"system")
            return 0
            ;;
    esac

    npm_bin="$HOME/.nvm/versions/node/$nvm_version/bin/npm"
    [ -x "$npm_bin" ] && printf '%s\n' "$npm_bin"
}

remove_npm_global_package() {
    local package_name=$1
    local prefix=${2:-}
    local prefix_args=()

    if [ -n "$prefix" ]; then
        [ -d "$prefix" ] || return 0
        prefix_args=(--prefix "$prefix")
    fi

    if npm list -g "${prefix_args[@]}" --depth=0 "$package_name" >/dev/null 2>&1; then
        log_info "Removing deprecated global npm package $package_name${prefix:+ from $prefix}..."
        npm uninstall -g "${prefix_args[@]}" "$package_name" >/dev/null 2>&1 || \
            log_warning "Failed to remove deprecated global package $package_name${prefix:+ from $prefix}"
    fi
}

ensure_current_global_npm_package() {
    local package_name=$1
    local install_spec=$2
    local resolved_spec=""

    if ! ensure_npm_available; then
        log_warning "npm is unavailable; cannot install $install_spec"
        return 1
    fi

    resolved_spec="$(resolve_npm_install_spec npm "$install_spec")"
    log_info "Installing/updating $package_name via npm..."
    if npm install -g "$resolved_spec"; then
        hash -r 2>/dev/null || true
        log_success "$package_name installed/updated"
        return 0
    fi

    log_warning "$package_name installation failed. Install manually:"
    log_info "  npm install -g $resolved_spec"
    return 1
}

ensure_nvm_default_global_npm_package() {
    local package_name=$1
    local install_spec=$2
    local npm_bin=""
    local active_prefix=""
    local nvm_prefix=""
    local resolved_spec=""

    npm_bin="$(nvm_default_npm_bin)"
    [ -n "$npm_bin" ] || return 0

    active_prefix="$(npm_global_prefix)"
    nvm_prefix="$("$npm_bin" prefix -g 2>/dev/null || true)"
    [ -n "$nvm_prefix" ] || return 0
    [ "$active_prefix" != "$nvm_prefix" ] || return 0

    resolved_spec="$(resolve_npm_install_spec "$npm_bin" "$install_spec")"
    log_info "Installing/updating $package_name in NVM default Node..."
    if "$npm_bin" install -g "$resolved_spec"; then
        hash -r 2>/dev/null || true
        log_success "$package_name installed/updated in NVM default Node"
        return 0
    fi

    log_warning "$package_name installation failed in NVM default Node. Install manually:"
    log_info "  $npm_bin install -g $resolved_spec"
    return 1
}

ensure_pi_package() {
    local package_name=$1
    local package_source=$2

    if ! command_exists pi; then
        log_warning "Pi CLI is unavailable; skipping Pi package $package_name"
        return 1
    fi

    if pi list 2>/dev/null | grep -Fq "$package_name"; then
        log_info "Pi package $package_name already installed"
        return 0
    fi

    log_info "Installing Pi package $package_name..."
    if pi install "$package_source"; then
        log_success "Pi package $package_name installed"
        return 0
    fi

    log_warning "Failed to install Pi package $package_name. Install manually:"
    log_info "  pi install $package_source"
    return 1
}

sync_pi_settings() {
    local settings_file="$HOME/.pi/agent/settings.json"
    local temp_file=""

    if ! command_exists jq; then
        log_warning "jq is unavailable; skipping Pi settings sync"
        return 1
    fi

    mkdir -p "$(dirname "$settings_file")"
    if [ ! -f "$settings_file" ]; then
        printf '{}\n' > "$settings_file"
    fi

    if ! jq empty "$settings_file" >/dev/null 2>&1; then
        log_warning "Pi settings file is not valid JSON; skipping settings sync: $settings_file"
        return 1
    fi

    temp_file="$(mktemp "${TMPDIR:-/tmp}/dotfiles-pi-settings.XXXXXX")"
    jq '
        def append_unique($items):
            reduce $items[] as $item (. // []; if index($item) then . else . + [$item] end);

        .defaultProvider = "neuralwatt"
        | .defaultModel = "glm-5.2"
        | .defaultThinkingLevel = "xhigh"
        | .packages = (.packages | append_unique(["npm:pi-mcp-adapter"]))
        | .skills = (.skills | append_unique(["~/.agents/skills"]))
    ' "$settings_file" > "$temp_file"

    mv "$temp_file" "$settings_file"
    chmod 600 "$settings_file"
    log_success "Pi settings synced for NeuralWatt GLM-5.2 and shared skills"
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

sync_claude_mcp_servers_from_json() {
    local config_file=$1
    local server_name=""
    local server_json=""
    local server_names=()
    local deprecated_server_names=("railway")

    if [ ! -f "$config_file" ]; then
        log_warning "Claude Code MCP config not found: $config_file"
        return 1
    fi

    if ! command_exists jq; then
        log_warning "jq is unavailable; skipping Claude Code MCP server sync"
        return 1
    fi

    if ! jq empty "$config_file" >/dev/null 2>&1; then
        log_warning "Claude Code MCP config is not valid JSON: $config_file"
        return 1
    fi

    while IFS= read -r server_name; do
        server_names+=("$server_name")
    done < <(jq -r '.mcpServers | keys[]' "$config_file")

    for server_name in "${deprecated_server_names[@]}"; do
        if [ -f "$HOME/.claude.json" ] && \
            jq -e --arg n "$server_name" '.mcpServers[$n]' "$HOME/.claude.json" >/dev/null 2>&1; then
            log_info "Removing deprecated Claude Code MCP server $server_name..."
            claude mcp remove "$server_name" --scope user >/dev/null 2>&1 || true
        fi
    done

    for server_name in "${server_names[@]}"; do
        server_json="$(jq -c --arg n "$server_name" '.mcpServers[$n]' "$config_file")"

        # Re-register on every run so URL/header/command changes propagate.
        # The JSON intentionally keeps ${VAR} placeholders literal; Claude Code
        # expands them at session start, avoiding secrets in ~/.claude.json.
        if [ -f "$HOME/.claude.json" ] && \
            jq -e --arg n "$server_name" '.mcpServers[$n]' "$HOME/.claude.json" >/dev/null 2>&1; then
            log_info "Refreshing Claude Code MCP server $server_name..."
            claude mcp remove "$server_name" --scope user >/dev/null 2>&1 || true
        else
            log_info "Adding Claude Code MCP server $server_name..."
        fi

        if claude mcp add-json --scope user "$server_name" "$server_json"; then
            log_success "Claude Code MCP server $server_name configured"
        else
            log_warning "Failed to add Claude Code MCP server $server_name. Add manually with claude mcp add-json."
        fi
    done
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
    "frontend-design@claude-plugins-official"
    "figma@claude-plugins-official"
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
# Claude Code MCP Servers (mirrors dotfiles/codex/config.toml)
# ============================================================================
if command_exists claude; then
    log_info "Configuring Claude Code MCP servers..."
    sync_claude_mcp_servers_from_json "$REPO_ROOT/dotfiles/claude/mcp.json"
fi

# ============================================================================
# Pi Coding Agent Installation (npm)
# ============================================================================
if ensure_npm_available; then
    active_npm_prefix="$(npm_global_prefix)"

    remove_npm_global_package "@mariozechner/pi-coding-agent"
    if [ "$active_npm_prefix" != "/opt/homebrew" ]; then
        remove_npm_global_package "@mariozechner/pi-coding-agent" "/opt/homebrew"
        remove_npm_global_package "@earendil-works/pi-coding-agent" "/opt/homebrew"
    fi

    ensure_current_global_npm_package "Pi coding agent" "@earendil-works/pi-coding-agent@latest"
    ensure_nvm_default_global_npm_package "Pi coding agent" "@earendil-works/pi-coding-agent@latest"
elif command_exists pi; then
    log_warning "npm is unavailable; leaving existing Pi coding agent in place"
else
    log_warning "Pi coding agent installation skipped because npm is unavailable"
    log_info "  npm install -g @earendil-works/pi-coding-agent@latest"
fi

if command_exists pi && pi --version 2>/dev/null; then
    log_success "Pi coding agent verified"
fi

# ============================================================================
# Pi ACP Installation (npm)
# ============================================================================
if ensure_npm_available; then
    remove_npm_global_package "pi-acp" "/opt/homebrew"
    ensure_current_global_npm_package "Pi ACP adapter" "pi-acp@latest"
    ensure_nvm_default_global_npm_package "Pi ACP adapter" "pi-acp@latest"
else
    log_warning "Pi ACP adapter installation skipped because npm is unavailable"
    log_info "  npm install -g pi-acp@latest"
fi

if command_exists pi-acp && pi-acp --version 2>/dev/null; then
    log_success "Pi ACP adapter verified"
fi

# ============================================================================
# Pi MCP Adapter Installation (Pi package)
# ============================================================================
if command_exists pi; then
    log_info "Ensuring Pi MCP adapter is installed..."
    ensure_pi_package "pi-mcp-adapter" "npm:pi-mcp-adapter"
    sync_pi_settings
fi

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
# Agent Browser Installation (Homebrew formula)
# ============================================================================
log_info "Setting up Agent Browser..."
if brew list --formula agent-browser >/dev/null 2>&1; then
    log_info "Agent Browser is already installed via Homebrew"
else
    if command_exists agent-browser; then
        log_warning "Agent Browser is installed outside Homebrew; installing the Homebrew formula for shared agent setup"
    fi

    log_info "Installing Agent Browser via Homebrew..."
    if brew install agent-browser; then
        log_success "Agent Browser installed successfully"
    else
        log_warning "Agent Browser installation failed. You can install manually:"
        log_info "  brew install agent-browser"
    fi
fi

if command_exists agent-browser; then
    if agent-browser --version 2>/dev/null; then
        log_success "Agent Browser verified"
    fi

    # Install Chromium for Agent Browser
    log_info "Ensuring Chromium is installed for Agent Browser..."
    if agent-browser install 2>/dev/null; then
        log_success "Chromium installed/verified for Agent Browser"
    else
        log_warning "Chromium installation skipped or failed. You can install manually:"
        log_info "  agent-browser install"
    fi
else
    log_warning "Agent Browser command is unavailable after installation attempt; skipping Chromium setup"
fi

log_success "AI tools setup completed!"
log_info "Remember to authenticate with each tool:"
log_info "  - Codex: codex login"
log_info "  - Claude Code: claude auth login"
log_info "  - Pi: pi, then /login (or export your provider API key)"
log_info "  - Railway CLI: railway login"
log_info "  - Vercel CLI: vercel login"
log_info "  - Figma MCP for Codex CLI: codex mcp login figma"
log_info "  - Figma MCP for Claude Code: run /mcp in Claude and authenticate figma"
log_info "  - Figma MCP for Claude Desktop and Zed: restart the app and approve OAuth"
log_info "  - Figma MCP for Pi: start OAuth from the pi-mcp-adapter mcp auth flow"
log_info "Restart Codex, Claude Code, Pi, and Zed after dotfiles sync so shared configs reload."
