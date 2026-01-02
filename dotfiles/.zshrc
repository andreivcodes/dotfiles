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

# Add Claude Code to PATH
export PATH="$HOME/.local/bin:$PATH"

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
# Usage: claude -u <profile> [args...]
#        codex -u <profile> [args...]
#        gemini -u <profile> [args...]
#        opencode -u <profile> [args...]
#
# Profile directories:
#   ~/.claude-profiles/<profile>/
#   ~/.codex-profiles/<profile>/
#   ~/.gemini-profiles/<profile>/
#   ~/.opencode-profiles/<profile>/
# ============================================================================

# Claude wrapper (uses CLAUDE_CONFIG_DIR)
unalias claude 2>/dev/null
claude() {
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
        echo "Error: -u <profile> is required. Usage: claude -u <profile> [args...]" >&2
        return 1
    fi

    echo "Claude Code profile: $profile"
    local profile_dir="$HOME/.claude-profiles/$profile"
    mkdir -p "$profile_dir"
    CLAUDE_CONFIG_DIR="$profile_dir" command claude "${cmd_args[@]}"
}

# Codex wrapper (uses CODEX_HOME)
unalias codex 2>/dev/null
codex() {
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
        echo "Error: -u <profile> is required. Usage: codex -u <profile> [args...]" >&2
        return 1
    fi

    echo "Codex profile: $profile"
    local profile_dir="$HOME/.codex-profiles/$profile"
    mkdir -p "$profile_dir"
    CODEX_HOME="$profile_dir" command codex "${cmd_args[@]}"
}

# Gemini wrapper (uses HOME override with symlinks to essential dirs)
unalias gemini 2>/dev/null
gemini() {
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
        echo "Error: -u <profile> is required. Usage: gemini -u <profile> [args...]" >&2
        return 1
    fi

    echo "Gemini profile: $profile"
    local profile_dir="$HOME/.gemini-profiles/$profile"
    mkdir -p "$profile_dir"

    # Create symlinks to essential directories from real home
    local dir
    for dir in Documents Downloads Desktop Pictures Music Videos; do
        if [[ -d "$HOME/$dir" ]] && [[ ! -e "$profile_dir/$dir" ]]; then
            ln -s "$HOME/$dir" "$profile_dir/$dir" 2>/dev/null || true
        fi
    done

    HOME="$profile_dir" command gemini "${cmd_args[@]}"
}

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

    XDG_DATA_HOME="$data_dir" OPENCODE_CONFIG_DIR="$config_dir" command opencode "${cmd_args[@]}"
}

# ============================================================================
# Additional Tools
# ============================================================================

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

# Amp CLI
export PATH="$HOME/.amp/bin:$PATH"

# direnv
command -v direnv >/dev/null && eval "$(direnv hook zsh)"
