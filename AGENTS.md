# Repository Guidelines for AI Agents

This document provides comprehensive guidelines for AI coding agents working in this macOS dotfiles repository. The repo automates the setup of a complete development environment including Homebrew packages, system preferences, and configuration files.

## Project Structure

```
dotfiles/
├── setup.sh              # Main entry point - runs full macOS setup
├── installers/           # Installation scripts
│   ├── all.sh            # Orchestrates all installers with progress tracking
│   ├── brew.sh           # Homebrew + Brewfile packages
│   ├── dev.sh            # NVM/Node, Bun, Rust toolchain + cargo tools
│   ├── dock.sh           # macOS Dock layout configuration
│   └── timemachine-exclude.sh  # Time Machine exclusions + Asimov
├── preferences/
│   └── system.sh         # macOS defaults (Finder, Dock, keyboard, etc.)
├── dotfiles/
│   ├── dotfiles.sh       # Symlink creation script
│   ├── .zshrc            # Zsh configuration with lazy loading
│   └── zed/              # Zed editor configuration
├── lib/
│   └── utils.sh          # Shared logging, guards, and helper functions
└── Brewfile              # Homebrew packages and casks
```

## Build, Lint, and Test Commands

### Linting (ShellCheck)

```bash
# Lint all shell scripts (primary validation method)
shellcheck installers/*.sh preferences/*.sh dotfiles/*.sh lib/*.sh

# Lint a single script
shellcheck installers/brew.sh

# Lint with explicit shell dialect
shellcheck -s bash installers/dev.sh
```

### Syntax Validation

```bash
# Check syntax without executing
bash -n installers/brew.sh
bash -n lib/utils.sh

# Validate all scripts
for f in installers/*.sh preferences/*.sh dotfiles/*.sh lib/*.sh; do bash -n "$f"; done
```

### Running Scripts

```bash
# Full setup (interactive, requires confirmation)
./setup.sh

# Individual installers (for testing specific modules)
bash installers/brew.sh           # Homebrew + packages
bash installers/dev.sh            # Dev toolchain (NVM, Rust)
bash installers/dock.sh           # Dock layout
bash installers/timemachine-exclude.sh
bash preferences/system.sh        # macOS defaults
bash dotfiles/dotfiles.sh         # Symlink configs

# With optional environment variables
INSTALL_CLAUDE=1 bash installers/brew.sh
```

### Testing a Single Component

There is no automated test suite. Testing is manual:

1. Run `bash -n <script>` to validate syntax
2. Run `shellcheck <script>` for linting
3. Execute the script directly to test functionality
4. Scripts have confirmation prompts for safe cancellation

## Code Style Guidelines

### Shell Script Header

Every script MUST start with:

```bash
#!/bin/bash

set -euo pipefail

# Source utility functions
source "$(dirname "$0")/../lib/utils.sh"

# Guards (as needed)
check_not_sudo
require_macos
```

### Formatting Rules (.editorconfig)

- **Indentation**: 2 spaces (never tabs, except Makefiles)
- **Line endings**: LF (Unix-style)
- **Final newline**: Required
- **Trailing whitespace**: Trim all
- **Charset**: UTF-8

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Scripts | `snake_case.sh` | `timemachine-exclude.sh` |
| Functions | `snake_case` | `log_info`, `safe_symlink` |
| Variables | `UPPER_SNAKE_CASE` | `REPO_ROOT`, `BREW_BIN` |
| Local vars | `lower_snake` | `local path=$1` |
| Arrays | `UPPER_SNAKE_CASE` | `SCRIPTS=()`, `DOCK_APPS=()` |

### Imports and Dependencies

```bash
# Always use relative path from script location
source "$(dirname "$0")/../lib/utils.sh"

# For scripts that need Homebrew environment
source "$HOME/.zprofile" 2>/dev/null || true
```

### Available Helper Functions (lib/utils.sh)

```bash
# Logging (colored output)
log_info "Message"       # Blue [INFO]
log_success "Message"    # Green [SUCCESS]
log_warning "Message"    # Yellow [WARNING]
log_error "Message"      # Red [ERROR] (to stderr)

# Progress tracking
show_progress "$current" "$total" "Task description"

# Guards
require_macos            # Exit if not Darwin
check_not_sudo           # Exit if running as root
check_sudo               # Exit if NOT running as root

# Utilities
command_exists <cmd>     # Check if command available
app_exists <Name.app>    # Check if /Applications/<Name.app> exists
backup_if_exists <path>  # Backup file/dir with timestamp
safe_symlink <src> <dst> # Create symlink with backup
confirm "Question?"      # Interactive y/N prompt
```

### Error Handling

```bash
# Use set -euo pipefail (already set via header)
# For commands that may fail but shouldn't stop execution:
brew update || log_warning "Update had issues, continuing..."

# For optional commands
sudo chflags nohidden /Volumes 2>/dev/null || true

# For critical operations
if ! some_command; then
    log_error "Critical failure"
    exit 1
fi
```

### Idempotency Patterns

Scripts MUST be safe to run multiple times:

```bash
# Check before installing
if command_exists brew; then
    log_info "Already installed"
else
    log_info "Installing..."
fi

# Check directories exist
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    # Install
fi

# Use safe_symlink (handles backup automatically)
safe_symlink "$source" "$target"
```

### Array Handling (Bash 3.2 Compatible)

macOS ships with Bash 3.2. Use parallel arrays instead of associative arrays:

```bash
# Parallel arrays pattern
SOURCES=("$REPO_ROOT/dotfiles/zed" "$REPO_ROOT/dotfiles/.zshrc")
TARGETS=("$HOME/.config/zed" "$HOME/.zshrc")

for i in "${!SOURCES[@]}"; do
    source="${SOURCES[$i]}"
    target="${TARGETS[$i]}"
    # Process...
done
```

## Security Guidelines

- **Never run `./setup.sh` with sudo** - scripts elevate internally when needed
- **No secrets in this repo** - configs only, use `.env` files outside VCS
- Guard scripts with `check_not_sudo` at the top
- Use `require_macos` for platform-specific scripts
- Avoid embedding tokens, API keys, or credentials

## Commit Message Format

Use Conventional Commits:

```
feat: add Time Machine exclusions for cargo registry
fix: handle brew upgrade errors gracefully
docs: update README with new installation steps
refactor: extract logging functions to lib/utils.sh
chore: update Brewfile dependencies
```

## Pull Request Guidelines

Include in PR description:
1. **Purpose**: What does this change accomplish?
2. **Scope**: Which scripts/configs are affected?
3. **Testing**: Commands run, macOS version tested
4. **Risks**: Potential issues and rollback steps

## Common Patterns

### Adding a New Installer

1. Create `installers/new-feature.sh` with standard header
2. Add to `SCRIPTS` and `DESCRIPTIONS` arrays in `installers/all.sh`
3. Run `shellcheck` and `bash -n` before committing

### Adding a New Dotfile

1. Place config in `dotfiles/` directory
2. Add source/target pair to `dotfiles/dotfiles.sh`
3. Document in `dotfiles.sh` comments

### Modifying Brewfile

```bash
# After editing Brewfile, test with:
brew bundle check --file=Brewfile   # Check what's missing
brew bundle install --file=Brewfile # Install packages
brew bundle cleanup --file=Brewfile # Remove unlisted (careful!)
```

## Troubleshooting

```bash
# Verify Xcode CLI tools
xcode-select -p

# Check Homebrew health
brew doctor

# Reset Dock to defaults (if dock.sh fails)
defaults delete com.apple.dock && killall Dock

# View Time Machine exclusions
sudo mdfind "com_apple_backup_excludeItem = 'com.apple.backupd'"
```
