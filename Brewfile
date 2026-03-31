# ============================================================================
# Brewfile - Homebrew Package Management
# ============================================================================
# Usage:
#   brew bundle install  - Install all packages from this file
#   brew bundle check    - Check if all packages are installed
#   brew bundle cleanup  - Uninstall packages not listed in this file
#   brew bundle dump     - Generate Brewfile from current installations
# ============================================================================

# ============================================================================
# Taps
# ============================================================================
tap "dopplerhq/cli"      # Doppler secrets management
tap "anomalyco/tap"      # OpenCode CLI (latest)
tap "oven-sh/bun"        # Bun JavaScript runtime
tap "mdnmdn/asimeow"     # Asimeow Time Machine exclusion manager

# ============================================================================
# CLI Tools & Utilities
# ============================================================================

# Package Management
brew "mas"              # Mac App Store CLI

# Development Tools
brew "nixpacks"         # Build and deploy apps
brew "act"              # Run GitHub Actions locally
brew "incus"            # CLI client for Incus containers
brew "gh"               # GitHub CLI
brew "ripgrep"          # Fast search (rg command)
brew "jq"               # JSON processor used by AI CLI integrations
brew "shellcheck"       # Shell script linter
brew "tree"             # Directory tree view
brew "direnv"           # Per-directory environment variables
brew "oven-sh/bun/bun"  # JavaScript runtime and package manager
brew "railway"          # Railway CLI

# Secrets Management
brew "gnupg"            # GPG encryption (required for Doppler)
brew "doppler"          # Secrets management CLI

# AI Tools
cask "codex"            # OpenAI Codex CLI (coding agent)
brew "anomalyco/tap/opencode" # OpenCode CLI (coding agent)
brew "agent-browser"    # Browser automation CLI for AI agents
# Note: Claude Code is installed via native installer (see installers/ai-tools.sh)

# ============================================================================
# Applications - AI
# ============================================================================
cask "claude"           # Anthropic Claude desktop app
cask "t3-code"          # T3 Code desktop app for AI coding agents

# System Utilities
brew "wget"             # Network downloader
brew "asimeow"          # Prevent Time Machine backups of dev folders
brew "displayplacer"    # Display scaling utility
brew "dockutil"         # Manage macOS Dock items from command line

# ============================================================================
# Applications - Communication
# ============================================================================
cask "discord"
cask "slack"
cask "whatsapp"
cask "telegram"

# ============================================================================
# Applications - Development
# ============================================================================
cask "zed@preview"      # Code editor
cask "github"           # GitHub Desktop
cask "tableplus"        # Database management
cask "figma"            # Design and prototyping tool
cask "docker"           # Container runtime

# ============================================================================
# Applications - Browsers & Network
# ============================================================================
cask "google-chrome"       # Web browser
cask "wifiman"             # WiFi analyzer

# ============================================================================
# Applications - Security & VPN
# ============================================================================
cask "1password"
cask "1password-cli"
cask "tailscale-app"    # Mesh VPN
cask "mullvad-vpn"      # Privacy VPN

# ============================================================================
# Applications - Productivity & Utilities
# ============================================================================
cask "notion"           # Notes and workspace
cask "rectangle"        # Window management
cask "keepingyouawake"  # Prevent sleep
cask "cleanshot"        # Screenshot tool
cask "balenaetcher"     # USB/SD card imaging
cask "macs-fan-control" # Fan control utility
