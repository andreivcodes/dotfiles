# Dotfiles

Personal macOS configuration files and development environment setup.

## Quick Start

```bash
git clone https://github.com/andreivcodes/dotfiles.git ~/git/dotfiles
cd ~/git/dotfiles
./setup.sh
```

## What's Included

- **Brewfile**: Declarative package management for Homebrew (CLI tools & applications)
- **Shell Configuration**: Performance-optimized .zshrc with Oh My Zsh and lazy loading
- **Zed Editor**: Complete settings with AI agent profiles and custom formatters
- **AI CLI Profiles**: Per-profile configuration for Codex, Claude Code, and OpenCode
- **Development Environment**: Node.js (via NVM), Rust, essential CLI tools
- **Installation Scripts**: Automated setup and symlink management

## Repository Structure

```
dotfiles/
├── README.md                  # This file
├── Brewfile                   # Homebrew package declarations (organized by category)
├── setup.sh                   # Main entry point for full setup
├── .gitignore                 # Files to exclude from git
├── installers/                # Setup scripts
│   ├── all.sh                 # Orchestrates all installation steps
│   ├── brew.sh                # Installs Homebrew packages
│   ├── dev.sh                 # Sets up development environment (Node.js, Rust)
│   ├── dock.sh                # Configures macOS Dock layout
│   └── timemachine-exclude.sh # Excludes dev directories from Time Machine
├── dotfiles/                  # Configuration files
│   ├── dotfiles.sh            # Creates symlinks for config files
│   ├── .zshrc                 # Zsh configuration (performance-optimized)
│   ├── zed/
│   │   └── settings.json      # Zed editor settings
│   ├── codex/                 # Codex CLI profile configs
│   ├── claude/                # Claude Code profile configs
│   └── opencode/              # OpenCode profile configs
├── preferences/               # macOS system preferences scripts
│   └── system.sh              # Configures Finder, Dock, Trackpad, etc.
└── lib/                       # Shared utility functions
    └── utils.sh               # Logging, progress tracking, error handling
```

## Installation

### Prerequisites

- macOS (tested on macOS 15.2+)
- [Homebrew](https://brew.sh/) installed
- [Oh My Zsh](https://ohmyz.sh/) installed

### Install Oh My Zsh Plugins

```bash
# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

### Full Setup (Recommended)

The `setup.sh` script provides a complete, automated installation:

```bash
# Clone and run full setup
git clone https://github.com/andreivcodes/dotfiles.git ~/git/dotfiles
cd ~/git/dotfiles
./setup.sh
```

This will:
- Install all Homebrew packages and applications
- Set up Node.js (via NVM) and Rust development environments
- Configure macOS system preferences (Finder, Dock, Trackpad, etc.)
- Create symlinks for dotfiles (.zshrc, Zed config, AI CLI profiles)
- Configure Dock layout with your applications
- Set up Time Machine exclusions for development directories

### Partial Setup (Individual Components)

You can also run individual setup scripts:

```bash
# Install packages only
bash installers/brew.sh

# Set up development environment only
bash installers/dev.sh

# Configure system preferences only
bash preferences/system.sh

# Create dotfile symlinks only
bash dotfiles/dotfiles.sh

# Configure Dock layout only
bash installers/dock.sh

# Configure Time Machine exclusions only
bash installers/timemachine-exclude.sh
```

## Key Features

### Shell Configuration (.zshrc)

- **⚡ Performance Optimized**: Lazy loading for nvm, cargo, and rust (dramatically faster shell startup)
- **📚 History Management**: 100k command history with deduplication and sharing across sessions
- **⌨️ Git Aliases**: Quick shortcuts for common git operations (gs, gc, gp, etc.)
- **🚀 Completion Caching**: Daily completion cache refresh for faster shell startup
- **🎨 Oh My Zsh Integration**: With carefully selected plugins for minimal performance impact

### AI CLI Profile Management

Use different profiles for personal and work contexts:

```bash
# Codex
codex -u personal
codex -u work

# Claude Code
claude -u personal
claude -u work

# OpenCode
opencode -u personal
opencode -u work
```

Each profile maintains separate:
- Configuration directories
- API keys and credentials
- Chat history and context

### Brewfile Package Management

Organized package declarations across categories:
- 📦 CLI tools and utilities (wget, ansible, act, etc.)
- 🤖 AI/ML CLIs (codex, opencode)
- 💻 Development tools (nixpacks, orbstack, zed)
- 💬 Communication apps (Discord, Slack, WhatsApp, Signal, Telegram)
- 🔒 Security and VPN tools (1Password, Tailscale, Mullvad)
- 🎯 Productivity utilities (Rectangle, CleanShot, TablePlus)

**Usage:**

The Brewfile stays in the repository (not symlinked to home directory). Use it with:

```bash
# From the dotfiles directory
cd ~/git/dotfiles
brew bundle install    # Install all packages
brew bundle check      # Check what's not installed
brew bundle cleanup    # Remove packages not in Brewfile

# Or from anywhere with --file flag
brew bundle install --file ~/git/dotfiles/Brewfile
brew bundle check --file ~/git/dotfiles/Brewfile

# Update Brewfile with current installations
cd ~/git/dotfiles
brew bundle dump --force
```

### Zed Editor Configuration

- **🤖 AI Agent Integration**: Codex agent server support
- **🎨 Custom Formatters**: Prettier for JavaScript, TypeScript, and TSX
- **📝 Git Integration**: Git gutter and inline blame
- **⚙️ Terminal Settings**: Integrated zsh terminal
- **🎨 Theme**: System-aware theme switching (One Light/One Dark)

## Performance Testing

### Measure Shell Startup Time

```bash
# Quick test
/usr/bin/time zsh -i -c exit
```

Expected result with optimizations: ~0.05-0.15 seconds (vs 0.5-1.5s without lazy loading)

### Profile Shell Initialization

```bash
# Add this to the top of ~/.zshrc temporarily:
zmodload zsh/zprof

# Reload shell and check profile:
exec zsh
# Then run:
zprof
```

## Maintenance

### Updating Packages

```bash
# Update Homebrew and packages
brew update && brew upgrade

# Update Oh My Zsh
omz update

# Update Oh My Zsh plugins
cd ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && git pull
cd ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && git pull
```

### Syncing Changes

The dotfiles are symlinked to your home directory, so changes made in `~/.zshrc` or `~/.config/zed/` are automatically reflected in the repository. Just commit and push:
```bash
cd ~/git/dotfiles
git add -A && git commit -m "Update dotfiles"
git push
```

### Backup Current Configuration

Before making changes, back up your current dotfiles:
```bash
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d)
```

## Troubleshooting

### Slow Shell Startup

1. Profile your shell to identify bottlenecks (see Performance Testing above)
2. Check if nvm/cargo are truly lazy-loaded: `type nvm` should show a function, not a path
3. Consider removing unused Oh My Zsh plugins from the plugins array
4. Run `brew doctor` to check for Homebrew issues

### Wrapper Functions Not Working

Ensure the CLI tools are installed:
```bash
which codex  # Should show path to codex
which claude # Should show path to claude
which opencode # Should show path to opencode
```

If not found, install:
```bash
# Codex
npm install -g @openai/codex

# Claude Code
curl -fsSL https://claude.ai/install.sh | bash

# OpenCode
brew install anomalyco/tap/opencode
```

### Completion Not Working

Rebuild the completion cache:
```bash
rm -f ~/.zcompdump
exec zsh
```

### Homebrew Issues

```bash
# Run diagnostics
brew doctor

# Fix common issues
brew cleanup
brew update
brew upgrade
```

## Security Notes

- 🔒 The `.gitignore` file prevents sensitive files from being committed
- 🔐 AI CLI wrappers create separate profile directories to isolate credentials
- ⚠️ `always_allow_tool_actions` in Zed bypasses security prompts - adjust if needed
- 🛡️ Profile wrappers ensure work and personal contexts remain separate

## Resources

### Official Documentation
- [Homebrew Documentation](https://docs.brew.sh/)
- [Homebrew Bundle](https://docs.brew.sh/Brew-Bundle-and-Brewfile)
- [Oh My Zsh](https://ohmyz.sh/)
- [Zed Editor](https://zed.dev/)

### Best Practices & Guides
- [Brewfile Best Practices](https://gist.github.com/ChristopherA/a579274536aab36ea9966f301ff14f3f)
- [Zsh Performance Optimization](https://blog.jonlu.ca/posts/speeding-up-zsh)
- [Oh My Zsh Performance Tips](https://blog.mattclemente.com/2020/06/26/oh-my-zsh-slow-to-load/)
- [Shell Function Wrappers](https://kevinjalbert.com/wrapping-shell-commands-and-keep-the-original-name/)
- [Zsh Best Practices](https://gist.github.com/ChristopherA/562c2e62d01cf60458c5fa87df046fbd)

## Contributing

This is a personal dotfiles repository, but feel free to fork and adapt for your own use. If you find bugs or have suggestions, please open an issue.

## License

MIT License - Feel free to use and modify as needed.

---

**Note**: This configuration is optimized for macOS. Some features may require adjustment for other operating systems.
