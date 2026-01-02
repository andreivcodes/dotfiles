#!/bin/bash

set -euo pipefail

# Source utility functions
source "$(dirname "$0")/../lib/utils.sh"

log_info "Starting comprehensive dotfiles setup..."

# Ensure not running as sudo
check_not_sudo
require_macos

# Define setup scripts and their descriptions
SCRIPT_DIR="$(dirname "$0")"
SCRIPTS=(
    "$SCRIPT_DIR/brew.sh"
    "$SCRIPT_DIR/dev.sh" 
    "$SCRIPT_DIR/../preferences/system.sh"
    "$SCRIPT_DIR/../dotfiles/dotfiles.sh"
    "$SCRIPT_DIR/dock.sh"
    "$SCRIPT_DIR/timemachine-exclude.sh"
)

DESCRIPTIONS=(
    "Installing applications and packages"
    "Setting up development environment"
    "Configuring macOS system preferences"
    "Setting up configuration files"
    "Configuring Dock layout"
    "Configuring Time Machine exclusions"
)

# Check if all scripts exist
log_info "Verifying all setup scripts exist..."
for script in "${SCRIPTS[@]}"; do
    if [ ! -f "$script" ]; then
        log_error "Setup script not found: $script"
        exit 1
    fi
    chmod +x "$script" 2>/dev/null || true
done

log_success "All setup scripts verified"

# Ask for confirmation before proceeding
echo
log_info "This will set up your complete macOS development environment including:"
echo "  • Homebrew packages and applications"
echo "  • Development tools (Node.js, Rust)" 
echo "  • System preferences and Finder settings"
echo "  • Configuration files (Zed, shell)"
echo "  • Dock layout"
echo "  • Time Machine exclusions for developer directories"
echo

if ! confirm "Proceed with full setup?"; then
    log_info "Setup cancelled by user"
    exit 0
fi

# Execute setup scripts
total=${#SCRIPTS[@]}
current=0
failed_scripts=()

for i in "${!SCRIPTS[@]}"; do
    script="${SCRIPTS[$i]}"
    description="${DESCRIPTIONS[$i]}"
    current=$((current + 1))
    
    echo
    show_progress "$current" "$total" "$description"
    log_info "Executing: $script"
    
    if bash "$script"; then
        log_success "Completed: $description"
    else
        log_error "Failed: $description"
        failed_scripts+=("$script")
        
        # Ask if user wants to continue after failure
        if ! confirm "Continue with remaining setup scripts?"; then
            log_info "Setup aborted by user"
            exit 1
        fi
    fi
done

# Summary
echo
echo "=============================================="
if [ ${#failed_scripts[@]} -eq 0 ]; then
    log_success "🎉 Complete dotfiles setup finished successfully!"
    log_info "Your macOS development environment is now configured"
    echo
    log_info "Next steps:"
    echo "  • Restart your terminal to load new shell configuration"
    echo "  • Open Zed to verify editor settings"
    echo "  • Check Dock layout and system preferences"
else
    log_warning "Setup completed with some failures:"
    for script in "${failed_scripts[@]}"; do
        log_error "  Failed: $script"
    done
    echo
    log_info "You may want to run the failed scripts manually"
fi
echo "=============================================="
