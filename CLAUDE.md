# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a comprehensive macOS dotfiles repository that automates the setup of a complete development environment including applications, system preferences, and development tools. It also contains Ansible playbooks for managing Proxmox infrastructure.

## Key Commands

### Main Setup
- `./setup` - Run complete dotfiles setup (installs everything)
- `bash installers/brew.sh` - Install Homebrew packages and applications only
- `bash installers/dev.sh` - Setup development environment (Node.js, Rust, Oh My Zsh)
- `bash preferences/system.sh` - Configure macOS system preferences
- `bash dotfiles/dotfiles.sh` - Setup configuration file symlinks
- `bash installers/dock.sh` - Configure Dock layout
- `bash installers/timemachine-exclude.sh` - Configure Time Machine exclusions

### Ansible Infrastructure Commands
- `cd infra/ansible && make deploy` - Deploy complete Proxmox configuration
- `cd infra/ansible && make deploy-ollama-lxc` - Deploy Ollama LXC container

## Architecture and Structure

### Setup Flow
The repository uses a modular bash script architecture:
1. **Entry point**: `setup` script executes `installers/all.sh`
2. **Orchestrator**: `installers/all.sh` runs scripts in sequence with error handling
3. **Utilities**: All scripts source `lib/utils.sh` for logging, progress tracking, and safety checks
4. **Safety**: Scripts check for sudo requirements and create backups before modifying files

### Key Design Patterns
- **Idempotency**: All scripts can be run multiple times safely - they check existing state before making changes
- **Error Recovery**: Scripts continue on failure and provide summary of any issues
- **User Confirmation**: Major changes require explicit user confirmation
- **Progress Tracking**: Visual indicators show progress through installation steps
- **Logging**: Color-coded status messages (INFO/SUCCESS/WARNING/ERROR)

### Configuration Management
- **Dotfiles**: Managed via symlinks from `dotfiles/` directory to home directory
- **Zed Editor**: Complete configuration including MCP servers, language settings, and agent profiles
- **Shell**: Oh My Zsh with custom plugins (git, docker, npm, rust, syntax highlighting, autosuggestions)
- **Claude Multi-Instance**: Custom wrapper function in `.zshrc` for managing multiple Claude profiles

### macOS Customizations
The `preferences/system.sh` script configures:
- Finder preferences (sidebar, hidden files, extensions)
- Dock settings (size, position, auto-hide)
- Trackpad (tap to click, three-finger drag)
- Keyboard (fast repeat rate, full keyboard access)
- Security (immediate password after sleep)
- Display scaling (More Space mode via displayplacer)
- Rectangle window management shortcuts

### Development Environment
- **Node.js**: Managed via NVM with automatic latest version installation
- **Rust**: Installed via rustup with cargo tools (cargo-edit, cargo-nextest, sea-orm-cli)
- **Package Managers**: npm, pnpm, Homebrew
- **Global npm packages**: pnpm, npm-check-updates

### Infrastructure as Code
The `infra/ansible/` directory contains Proxmox automation:
- Complete Proxmox VE setup with ZFS, networking, SDN, GPU passthrough
- PBS (Proxmox Backup Server) configuration
- LXC container management with GPU support
- Tailscale VPN integration
- Automated backup job configuration

## Important Implementation Notes

- Never use `sudo` with the main setup scripts - they handle permissions internally
- The repository expects to be cloned to `~/git/dotfiles` for symlinks to work correctly
- Time Machine exclusions use `asimov` to automatically exclude developer directories
- GPU passthrough configuration supports dual RTX 3090 cards for LXC containers
- Ansible playbooks expect a `.vault_pass` file for encrypted variables
- The Claude wrapper function requires the `-u` parameter to specify the profile

## Testing and Validation

While there are no formal test scripts, validation occurs through:
- Script exit codes and error handling
- Service status checks in Ansible playbooks
- Visual confirmation prompts during setup
- Summary reports after each script completes