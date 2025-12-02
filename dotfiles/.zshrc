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
HISTFILE=~/.zsh_history
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
source $ZSH/oh-my-zsh.sh

# ============================================================================
# User Configuration
# ============================================================================

# Add Claude Code to PATH
export PATH="$HOME/.local/bin:$PATH"

# ============================================================================
# NVM Setup (Lazy Loaded for Performance)
# ============================================================================
export NVM_DIR="$HOME/.nvm"

# Lazy load nvm - only load when nvm/node/npm is called
nvm() {
  unset -f nvm node npm
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  nvm "$@"
}

node() {
  unset -f nvm node npm
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  node "$@"
}

npm() {
  unset -f nvm node npm
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  npm "$@"
}

# ============================================================================
# Rust Setup (Lazy Loaded for Performance)
# ============================================================================
cargo() {
  unset -f cargo rustc
  [ -s "$HOME/.cargo/env" ] && \. "$HOME/.cargo/env"
  cargo "$@"
}

rustc() {
  unset -f cargo rustc
  [ -s "$HOME/.cargo/env" ] && \. "$HOME/.cargo/env"
  rustc "$@"
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
# ============================================================================

# Generic wrapper factory for simple config-based CLIs
_create_profile_wrapper() {
    local cmd=$1
    local env_var=$2
    local display_name=$3

    unalias "$cmd" 2>/dev/null
    eval "$cmd() {
        local config_value=\"\"
        local cmd_args=()
        local user_provided=false

        # Parse arguments
        while [[ \$# -gt 0 ]]; do
            case \$1 in
                -u)
                    if [[ -n \"\$2\" && \"\$2\" != -* ]]; then
                        config_value=\"\$2\"
                        user_provided=true
                        shift 2
                    else
                        echo \"Error: -u requires a value\" >&2
                        return 1
                    fi
                    ;;
                *)
                    cmd_args+=(\"\$1\")
                    shift
                    ;;
            esac
        done

        # Validate required parameter
        if [[ \"\$user_provided\" = false ]]; then
            echo \"Error: -u parameter is required. Usage: $cmd -u <profile> [args...]\" >&2
            return 1
        fi

        echo \"$display_name user: \$config_value\"

        # Set environment and run command
        local config_dir=\"\$HOME/.$cmd-\$config_value\"
        mkdir -p \"\$config_dir\"
        $env_var=\"\$config_dir\" command $cmd \"\${cmd_args[@]}\"
    }"
}

# Create wrappers for Claude and Codex (similar pattern)
_create_profile_wrapper claude CLAUDE_CONFIG_DIR "Claude Code"
_create_profile_wrapper codex CODEX_HOME "Codex"

# Gemini wrapper (special case - uses HOME and creates symlinks)
unalias gemini 2>/dev/null
gemini() {
    local config_value=""
    local gemini_args=()
    local user_provided=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -u)
                if [[ -n "$2" && "$2" != -* ]]; then
                    config_value="$2"
                    user_provided=true
                    shift 2
                else
                    echo "Error: -u requires a value" >&2
                    return 1
                fi
                ;;
            *)
                gemini_args+=("$1")
                shift
                ;;
        esac
    done

    # Validate required parameter
    if [[ "$user_provided" = false ]]; then
        echo "Error: -u parameter is required. Usage: gemini -u <profile> [args...]" >&2
        return 1
    fi

    echo "Gemini user: $config_value"

    # Create profile-specific HOME directory
    local gemini_profile_home="$HOME/.gemini-profiles/$config_value"
    mkdir -p "$gemini_profile_home"

    # Create symlinks to essential directories from real home
    local dir
    for dir in Documents Downloads Desktop Pictures Music Videos; do
        if [[ -d "$HOME/$dir" ]] && [[ ! -e "$gemini_profile_home/$dir" ]]; then
            ln -s "$HOME/$dir" "$gemini_profile_home/$dir" 2>/dev/null || true
        fi
    done

    # Run gemini with the profile-specific HOME
    HOME="$gemini_profile_home" command gemini "${gemini_args[@]}"
}

# ============================================================================
# Additional Tools
# ============================================================================

# pnpm
export PNPM_HOME="/Users/andrei/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Antigravity
export PATH="/Users/andrei/.antigravity/antigravity/bin:$PATH"

# ============================================================================
# Completion System (Optimized)
# ============================================================================
# Docker CLI completions
fpath=(/Users/andrei/.docker/completions $fpath)

# Speed up compinit by only checking cache once a day
autoload -Uz compinit
if [[ -n ${HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
