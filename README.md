# Dotfiles Setup

Complete macOS development environment setup with applications, system preferences, and configurations.

## Quick Start

```bash
git clone https://github.com/andreivcodes/dotfiles.git && cd dotfiles
./setup
```

## What It Sets Up

- **Applications**: Homebrew packages, development tools, communication apps
- **System Preferences**: Finder, Dock, Trackpad, Keyboard, Security settings  
- **Development Environment**: Node.js (via NVM), Rust, essential CLI tools
- **Configuration Files**: Zed editor, shell (zsh), dotfile symlinks

## Repository Structure

```
dotfiles/
├── setup                   # 🚀 Main entry point script
├── installers/            # 📦 Application and tool installers
│   ├── all.sh             #   Orchestrates all setup scripts
│   ├── brew.sh            #   Installs packages/apps via Brewfile (brew bundle)
│   ├── dev.sh             #   Sets up Node.js and Rust development
│   └── dock.sh            #   Configures macOS Dock layout
├── preferences/           # ⚙️  macOS system preferences
│   └── system.sh          #   Configures Finder, Dock, Trackpad, etc.
├── dotfiles/              # 🔧 Configuration files and dotfiles
│   ├── dotfiles.sh        #   Symlinks configurations to home directory
│   ├── .zshrc             #   Shell configuration with Claude multi-instance
│   └── zed/               #   Zed editor configuration
└── lib/                   # 🛠️ Utility functions and helpers
    └── utils.sh           #   Logging, progress tracking, error handling
```

## Individual Scripts

You can run components individually if needed:

```bash
# Install applications and packages only (uses Brewfile)
bash installers/brew.sh

# Setup development environment only  
bash installers/dev.sh

# Configure system preferences only
bash preferences/system.sh

# Setup configuration files only
bash dotfiles/dotfiles.sh

# Configure Dock layout only
bash installers/dock.sh
```

## Features

- **🎯 Progress Tracking**: Visual progress indicators for all operations
- **🛡️ Error Handling**: Continues on failure, shows summary of issues
- **🔄 Idempotency**: Safe to run multiple times, skips already installed items
- **✋ User Confirmation**: Asks before making major changes
- **📊 Detailed Logging**: Color-coded status messages with clear feedback
- **🔒 Safety Checks**: Prevents running with sudo when inappropriate
- **💾 Auto Backup**: Backs up existing configurations before overwriting
