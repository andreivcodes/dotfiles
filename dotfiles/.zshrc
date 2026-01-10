# ============================================================================
# Oh My Zsh Configuration
# ============================================================================

# Path to your oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load (using default robbyrussell)
ZSH_THEME="robbyrussell"

# ============================================================================
# History Configuration
# ============================================================================
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY           # Share history between sessions
setopt HIST_IGNORE_DUPS        # Don't record duplicates
setopt HIST_IGNORE_SPACE       # Don't record commands starting with space
setopt HIST_VERIFY             # Show command with history expansion before running

# ============================================================================
# Oh My Zsh Settings
# ============================================================================

# Uncomment the following line to use case-sensitive completion
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion
# Case-sensitive completion must be off. _ and - will be interchangeable
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to automatically update without prompting
DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days)
export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to enable command auto-correction
# ENABLE_CORRECTION="true"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(
    git
    macos
    brew
    docker
    npm
    node
    nvm
    rust
    command-not-found
    colored-man-pages
    zsh-autosuggestions
    zsh-syntax-highlighting
)

# Load Oh My Zsh
source "$ZSH/oh-my-zsh.sh"

# ============================================================================
# User Configuration
# ============================================================================

# ============================================================================
# NVM Setup (Lazy Loaded for Performance)
# ============================================================================
export NVM_DIR="$HOME/.nvm"

# Lazy load nvm - only load when nvm/node/npm/npx is called
nvm() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  nvm "$@"
}

node() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  node "$@"
}

npm() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  npm "$@"
}

npx() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  npx "$@"
}

# ============================================================================
# Rust Setup (Lazy Loaded for Performance)
# ============================================================================
cargo() {
  unset -f cargo rustc rustup
  [ -s "$HOME/.cargo/env" ] && \. "$HOME/.cargo/env"
  cargo "$@"
}

rustc() {
  unset -f cargo rustc rustup
  [ -s "$HOME/.cargo/env" ] && \. "$HOME/.cargo/env"
  rustc "$@"
}

rustup() {
  unset -f cargo rustc rustup
  [ -s "$HOME/.cargo/env" ] && \. "$HOME/.cargo/env"
  rustup "$@"
}

# ============================================================================
# Aliases
# ============================================================================

# File listing
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Git shortcuts
alias gs='git status'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gco='git checkout'
alias gb='git branch'
alias ga='git add'
alias gd='git diff'

# ============================================================================
# AI CLI Profile Wrapper Functions
# ============================================================================
# These wrappers allow running AI CLIs with different user profiles
# Usage: opencode -u <profile> [args...]
#
# Profile directories:
#   ~/.opencode-profiles/<profile>/
# ============================================================================

# OpenCode wrapper (uses XDG_DATA_HOME for auth, OPENCODE_CONFIG_DIR for config)
unalias opencode 2>/dev/null
opencode() {
    local profile=""
    local cmd_args=()

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -u)
                if [[ -n "$2" && "$2" != -* ]]; then
                    profile="$2"
                    shift 2
                else
                    echo "Error: -u requires a profile name" >&2
                    return 1
                fi
                ;;
            *)
                cmd_args+=("$1")
                shift
                ;;
        esac
    done

    if [[ -z "$profile" ]]; then
        echo "Error: -u <profile> is required. Usage: opencode -u <profile> [args...]" >&2
        return 1
    fi

    echo "OpenCode profile: $profile"
    local profile_dir="$HOME/.opencode-profiles/$profile"
    local data_dir="$profile_dir/data"
    local config_dir="$profile_dir/config"
    mkdir -p "$data_dir" "$config_dir"

    OPENCODE_CONFIG="$config_dir/opencode.json" XDG_DATA_HOME="$data_dir" OPENCODE_CONFIG_DIR="$config_dir" command opencode "${cmd_args[@]}"
}

# Claude Code wrapper (uses CLAUDE_CONFIG_DIR for config isolation)
# Note: CLAUDE_CONFIG_DIR has known limitations (GitHub #15670):
#   - Session resume (--resume) may not work across profiles
#   - VS Code integration uses ~/.claude/ regardless
#   - Parallel profile execution may have SQLite lock issues
unalias claude 2>/dev/null
claude() {
    local profile=""
    local cmd_args=()
    local bypass_profile=false

    # Check if first arg is a maintenance command that doesn't need a profile
    case "$1" in
        update|install|uninstall|--version|-v|--help|-h)
            bypass_profile=true
            ;;
    esac

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -u)
                if [[ -n "$2" && "$2" != -* ]]; then
                    profile="$2"
                    shift 2
                else
                    echo "Error: -u requires a profile name" >&2
                    return 1
                fi
                ;;
            *)
                cmd_args+=("$1")
                shift
                ;;
        esac
    done

    # For maintenance commands, run directly without profile isolation
    if [[ "$bypass_profile" == true ]]; then
        local claude_bin="${HOME}/.local/bin/claude"
        [[ ! -x "$claude_bin" ]] && claude_bin="${HOME}/.claude/bin/claude"
        [[ ! -x "$claude_bin" ]] && claude_bin="$(command -v claude)"
        "$claude_bin" "${cmd_args[@]}"
        return $?
    fi

    if [[ -z "$profile" ]]; then
        echo "Error: -u <profile> is required. Usage: claude -u <profile> [args...]" >&2
        return 1
    fi

    echo "Claude Code profile: $profile"
    local profile_dir="$HOME/.claude-profiles/$profile"
    local config_dir="$profile_dir/config"
    mkdir -p "$profile_dir/data" "$config_dir"

    local agents_file="$config_dir/AGENTS.md"
    local mcp_file="$config_dir/mcp.json"
    local agents_content=""
    local -a extra_args=()

    # Add MCP config if it exists
    if [[ -f "$mcp_file" ]]; then
        extra_args+=(--mcp-config "$mcp_file")
    fi

    # Add AGENTS.md as system prompt if it exists
    if [[ -f "$agents_file" ]]; then
        agents_content="$(cat "$agents_file")"
        extra_args+=(--append-system-prompt "$agents_content")
    fi

    # Execute with config directory set and profile env var for status line
    # Use full path to avoid issues with env not finding the binary
    local claude_bin="${HOME}/.local/bin/claude"
    [[ ! -x "$claude_bin" ]] && claude_bin="${HOME}/.claude/bin/claude"
    [[ ! -x "$claude_bin" ]] && claude_bin="$(command -v claude)"

    if [[ ! -x "$claude_bin" ]]; then
        echo "Error: claude not found. Install: curl -fsSL https://claude.ai/install.sh | bash" >&2
        return 1
    fi

    CLAUDE_CONFIG_DIR="$config_dir" CLAUDE_PROFILE="$profile" "$claude_bin" "${extra_args[@]}" "${cmd_args[@]}"
}

# ============================================================================
# Additional Tools
# ============================================================================

# OpenCode Configuration
export OPENCODE_EXPERIMENTAL=true
export OPENCODE_EXPERIMENTAL_LSP_TOOL=true
export OPENCODE_EXPERIMENTAL_OXFMT=true
export OPENCODE_EXPERIMENTAL_ICON_DISCOVERY=true

# Load private environment variables (API keys, secrets)
# Create ~/.zshrc.local with: export EXA_API_KEY="your-key-here"
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac



# ============================================================================
# Completion System (Optimized)
# ============================================================================
# Docker CLI completions
[[ -d "$HOME/.docker/completions" ]] && fpath=("$HOME/.docker/completions" $fpath)

# Speed up compinit by only checking cache once a day
autoload -Uz compinit
# shellcheck disable=SC1036,SC1072,SC1073,SC1009
if [[ -n ${HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# claude code (native installer uses ~/.local/bin)
export PATH="$HOME/.local/bin:$HOME/.claude/bin:$PATH"

# Amp CLI
export PATH="$HOME/.amp/bin:$PATH"

# direnv
command -v direnv >/dev/null && eval "$(direnv hook zsh)"
