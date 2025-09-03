# Path to your oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load (using default robbyrussell)
ZSH_THEME="robbyrussell"

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

# User configuration

# Add Claude Code to PATH
export PATH="$HOME/.local/bin:$PATH"

# NVM setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Rust setup
[ -s "$HOME/.cargo/env" ] && \. "$HOME/.cargo/env"

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias gs='git status'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gco='git checkout'
alias gb='git branch'
alias ga='git add'
alias gd='git diff'

# Claude wrapper function
unalias claude 2>/dev/null
claude() {
    local config_value=""
    local claude_args=()
    local user_provided=false
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
                claude_args+=("$1")
                shift
                ;;
        esac
    done
    if [[ "$user_provided" = false ]]; then
        echo "Error: -u parameter is required. Usage: claude -u <profile> [args...]" >&2
        return 1
    fi
    echo "Claude Code user: $config_value."
    CLAUDE_CONFIG_DIR="$HOME/.claude-$config_value" command claude "${claude_args[@]}"
}

# Codex wrapper function
unalias codex 2>/dev/null
codex() {
    local config_value=""
    local codex_args=()
    local user_provided=false
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
                codex_args+=("$1")
                shift
                ;;
        esac
    done
    if [[ "$user_provided" = false ]]; then
        echo "Error: -u parameter is required. Usage: codex -u <profile> [args...]" >&2
        return 1
    fi
    echo "Codex user: $config_value."
    # Set the config directory based on profile
    export CODEX_CONFIG_DIR="$HOME/.codex-$config_value"
    # Ensure the config directory exists
    mkdir -p "$CODEX_CONFIG_DIR"
    # Create symlink for config.toml if it doesn't exist
    if [[ ! -f "$CODEX_CONFIG_DIR/config.toml" ]]; then
        # Copy the default config if it exists
        if [[ -f "$HOME/.codex/config.toml" ]]; then
            cp "$HOME/.codex/config.toml" "$CODEX_CONFIG_DIR/config.toml"
        fi
    fi
    # Run codex with the custom config directory
    HOME="$HOME" XDG_CONFIG_HOME="$CODEX_CONFIG_DIR/.." command codex "${codex_args[@]}"
}

# Gemini wrapper function
unalias gemini 2>/dev/null
gemini() {
    local config_value=""
    local gemini_args=()
    local user_provided=false
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
    if [[ "$user_provided" = false ]]; then
        echo "Error: -u parameter is required. Usage: gemini -u <profile> [args...]" >&2
        return 1
    fi
    echo "Gemini user: $config_value."
    # Set the config directory based on profile
    export GEMINI_CONFIG_DIR="$HOME/.gemini-$config_value"
    # Ensure the config directory exists
    mkdir -p "$GEMINI_CONFIG_DIR"
    # Set environment variables for Gemini to use the custom config
    export GEMINI_DATA_DIR="$GEMINI_CONFIG_DIR"
    export GEMINI_STATE_DIR="$GEMINI_CONFIG_DIR/state"
    # Run gemini with the custom config directory
    HOME="$HOME" XDG_CONFIG_HOME="$GEMINI_CONFIG_DIR/.." XDG_DATA_HOME="$GEMINI_CONFIG_DIR" command gemini "${gemini_args[@]}"
}
