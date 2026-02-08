# macOS Dotfiles - Agent Guidelines

This repository automates macOS development environment setup with Homebrew packages, system preferences, and configuration files.

## Project Structure

- `setup.sh` - Main entry point (runs full macOS setup)
- `installers/` - Installation scripts (brew.sh, dev.sh, dock.sh, timemachine-exclude.sh, all.sh)
- `preferences/system.sh` - macOS defaults (Finder, Dock, keyboard, etc.)
- `dotfiles/` - Config files (.zshrc, codex/, zed/) and dotfiles.sh symlink script
- `lib/utils.sh` - Shared logging, guards, and helper functions
- `Brewfile` - Homebrew packages and casks

## Build, Lint, and Test Commands

```bash
# Lint all shell scripts
shellcheck installers/*.sh preferences/*.sh dotfiles/*.sh lib/*.sh

# Lint a single script
shellcheck installers/brew.sh

# Syntax check without executing
bash -n installers/brew.sh

# Run full setup (interactive)
./setup.sh

# Test individual components
bash installers/brew.sh           # Homebrew + packages
bash installers/dev.sh            # Dev toolchain
bash dotfiles/dotfiles.sh         # Symlink configs

# With optional environment variables
INSTALL_CLAUDE=1 bash installers/brew.sh
```

**Testing**: No automated tests. Validate with `bash -n` + `shellcheck`, then execute. Scripts have confirmation prompts.

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

### Formatting
- Indentation: 2 spaces (tabs only in Makefiles)
- Line endings: LF, final newline required, trim trailing whitespace

### Naming Conventions
| Element | Convention | Example |
|---------|------------|---------|
| Scripts | `snake_case.sh` | `timemachine-exclude.sh` |
| Functions | `snake_case` | `log_info`, `safe_symlink` |
| Variables | `UPPER_SNAKE_CASE` | `REPO_ROOT`, `BREW_BIN` |
| Local vars | `lower_snake` | `local path=$1` |
| Arrays | `UPPER_SNAKE_CASE` | `SCRIPTS=()`, `DOCK_APPS=()` |

### Imports
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

### Idempotency & Arrays
Scripts MUST be safe to run multiple times. Check before installing, use `safe_symlink` for automatic backups.

macOS ships with Bash 3.2 - use parallel arrays instead of associative arrays:
```bash
SOURCES=("$REPO_ROOT/dotfiles/zed" "$REPO_ROOT/dotfiles/.zshrc")
TARGETS=("$HOME/.config/zed" "$HOME/.zshrc")
for i in "${!SOURCES[@]}"; do
    safe_symlink "${SOURCES[$i]}" "${TARGETS[$i]}"
done
```

## Security Guidelines
- **Never run `./setup.sh` with sudo** - scripts elevate internally when needed
- **No secrets in this repo** - Use `~/.zshrc.local` for API keys (gitignored)
- Guard scripts with `check_not_sudo` at the top
- Use `require_macos` for platform-specific scripts

## Common Patterns

### Adding a New Installer
1. Create `installers/new-feature.sh` with standard header
2. Add to `SCRIPTS` and `DESCRIPTIONS` arrays in `installers/all.sh`
3. Run `shellcheck` and `bash -n` before committing

### Adding a New Dotfile
1. Place config in `dotfiles/` directory
2. Add source/target pair to `dotfiles/dotfiles.sh`
3. Run `bash dotfiles/dotfiles.sh` to test symlink creation

### Modifying Brewfile
```bash
brew bundle check --file=Brewfile   # Check what's missing
brew bundle install --file=Brewfile # Install packages
brew bundle cleanup --file=Brewfile # Remove unlisted (careful!)
```
