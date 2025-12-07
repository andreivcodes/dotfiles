#!/bin/bash

set -euo pipefail

# Source utility functions
source "$(dirname "$0")/../lib/utils.sh"

log_info "Starting Time Machine exclusion setup..."

# Ensure not running as sudo
check_not_sudo
require_macos

# Function to exclude specific paths
exclude_paths() {
    local paths=("$@")

    for path in "${paths[@]}"; do
        if [ -e "$path" ]; then
            if tmutil addexclusion "$path" 2>/dev/null; then
                log_success "Excluded: $path"
            else
                log_warning "Failed to exclude: $path"
            fi
        fi
    done
}

# Exclude cache and temporary directories (not handled by Asimov)
CACHE_PATHS=(
    "$HOME/Library/Caches"
    "$HOME/.npm"
    "$HOME/.yarn"
    "$HOME/.pnpm-store"
    "$HOME/.cargo/registry"
    "$HOME/.cargo/git"
    "$HOME/.rustup"
    "$HOME/.gradle"
    "$HOME/.m2/repository"
    "$HOME/.ivy2"
    "$HOME/.sbt"
    "$HOME/.docker"
    "$HOME/Library/Developer/Xcode/DerivedData"
    "$HOME/Library/Developer/CoreSimulator"
)

log_info "Excluding cache directories..."
exclude_paths "${CACHE_PATHS[@]}"

# Run Asimov - handles node_modules, vendor, target, Pods, Carthage, etc.
# Asimov is smarter: checks for package.json before excluding node_modules
log_info "Running Asimov to exclude development dependencies..."
if command -v asimov >/dev/null 2>&1; then
    if asimov; then
        log_success "Asimov completed successfully"
    else
        log_warning "Asimov encountered some issues"
    fi

    # Enable Asimov as a daily service
    log_info "Enabling Asimov daily service..."
    if sudo brew services start asimov 2>/dev/null; then
        log_success "Asimov service enabled (runs daily)"
    else
        log_warning "Could not enable Asimov service. Run manually: sudo brew services start asimov"
    fi
else
    log_error "Asimov not found. Install with: brew install asimov"
    exit 1
fi

log_success "Time Machine exclusion setup completed!"
log_info "Asimov handles: node_modules, vendor, target, Pods, Carthage, bower_components, .build, stack-work"
log_info "Asimov runs daily to automatically exclude new dependency directories."
