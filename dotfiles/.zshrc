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
# AI CLI Integration
# ============================================================================

# Claude Code wrapper to load the repo-managed MCP config from ~/.claude/mcp.json.
# Codex and OpenCode use their documented shared config directories directly.
unalias claude 2>/dev/null
claude() {
    local claude_bin="${HOME}/.local/bin/claude"
    local use_repo_mcp=true

    [[ ! -x "$claude_bin" ]] && claude_bin="${HOME}/.claude/bin/claude"
    [[ ! -x "$claude_bin" ]] && claude_bin="$(whence -p claude 2>/dev/null || true)"
    if [[ ! -x "$claude_bin" ]]; then
        echo "Error: claude not found. Install: curl -fsSL https://claude.ai/install.sh | bash" >&2
        return 1
    fi

    for arg in "$@"; do
        case "$arg" in
            --mcp-config|--mcp-config=*)
                use_repo_mcp=false
                break
                ;;
        esac
    done

    if [[ "$use_repo_mcp" == true && -f "$HOME/.claude/mcp.json" ]]; then
        "$claude_bin" --mcp-config "$HOME/.claude/mcp.json" "$@"
    else
        "$claude_bin" "$@"
    fi
}

# ============================================================================
# Additional Tools
# ============================================================================

# Enable the local developer harness by default in new shells.
export AGENT_HARNESS=1

# Load private environment variables (API keys, secrets)
# Create ~/.zshrc.local with entries like:
# export CONTEXT7_API_KEY="your-context7-key"
# export EXA_API_KEY="your-exa-key"
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

# claude code (native installer uses ~/.local/bin)
export PATH="$HOME/.local/bin:$HOME/.claude/bin:$PATH"

# Amp CLI
export PATH="$HOME/.amp/bin:$PATH"

# direnv
command -v direnv >/dev/null && eval "$(direnv hook zsh)"

# Added by LM Studio CLI (lms)
if [ -d "$HOME/.lmstudio/bin" ]; then
  export PATH="$PATH:$HOME/.lmstudio/bin"
fi
# End of LM Studio CLI section

# opencode
export PATH="$HOME/.opencode/bin:$PATH"
