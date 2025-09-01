#!/bin/bash

set -euo pipefail

# Source utility functions
source "$(dirname "$0")/../lib/utils.sh"

log_info "Starting Time Machine exclusion setup..."

# Ensure not running as sudo
check_not_sudo

# Function to exclude directories matching patterns
exclude_directories() {
    local pattern="$1"
    local description="$2"
    
    log_info "Excluding $description directories..."
    
    # Find directories in common development locations
    local search_paths=(
        "$HOME/git"
        "$HOME/projects"
        "$HOME/code"
        "$HOME/dev"
        "$HOME/Development"
        "$HOME/Documents"
        "$HOME/Desktop"
    )
    
    local count=0
    for search_path in "${search_paths[@]}"; do
        if [ -d "$search_path" ]; then
            while IFS= read -r -d '' dir; do
                if tmutil addexclusion "$dir" 2>/dev/null; then
                    log_success "Excluded: $dir"
                    count=$((count + 1))
                else
                    log_warning "Failed to exclude: $dir"
                fi
            done < <(find "$search_path" -type d -name "$pattern" -print0 2>/dev/null)
        fi
    done
    
    log_info "Excluded $count $description directories"
}

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
        else
            log_info "Path doesn't exist, skipping: $path"
        fi
    done
}

# Exclude common developer dependency directories
exclude_directories "node_modules" "Node.js dependencies"
exclude_directories "target" "Rust/Java build outputs"
exclude_directories "vendor" "PHP/Ruby dependencies"
exclude_directories ".venv" "Python virtual environments"
exclude_directories "venv" "Python virtual environments"
exclude_directories ".terraform" "Terraform state"
exclude_directories "bower_components" "Bower packages"
exclude_directories ".build" "Swift build outputs"
exclude_directories "Carthage" "iOS Carthage dependencies"
exclude_directories "Pods" "iOS CocoaPods dependencies"
exclude_directories ".stack-work" "Haskell Stack work"
exclude_directories "__pycache__" "Python bytecode cache"
exclude_directories ".pytest_cache" "PyTest cache"
exclude_directories ".tox" "Tox environments"
exclude_directories "dist" "Build distributions"
exclude_directories "build" "Build outputs"
exclude_directories ".gradle" "Gradle cache"
exclude_directories ".nuxt" "Nuxt.js cache"
exclude_directories ".next" "Next.js cache"
exclude_directories ".cache" "General cache directories"

# Exclude common cache and temporary directories
CACHE_PATHS=(
    "$HOME/Library/Caches"
    "$HOME/.npm"
    "$HOME/.yarn"
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

log_info "Excluding cache and temporary directories..."
exclude_paths "${CACHE_PATHS[@]}"

# Run Asimov to automatically handle dependency directories
log_info "Running Asimov to automatically exclude dependency directories..."
if command -v asimov >/dev/null 2>&1; then
    if asimov; then
        log_success "Asimov completed successfully"
    else
        log_warning "Asimov encountered some issues"
    fi
else
    log_warning "Asimov not found. Install with: brew install asimov"
fi

# Show current exclusions (skip if command fails - requires admin on newer macOS)
log_info "Attempting to show current Time Machine exclusions..."
if tmutil listexclusions 2>/dev/null | head -20; then
    log_info "Exclusions listed above"
else
    log_info "Note: Listing exclusions requires admin privileges on newer macOS versions"
fi

log_success "Time Machine exclusion setup completed!"
log_info "Benefits:"
log_info "  • Faster backups (excluding millions of dependency files)"
log_info "  • Less storage usage on backup drive"
log_info "  • Dependencies can be restored with package managers"
log_info ""
log_info "To manually exclude additional directories:"
log_info "  tmutil addexclusion /path/to/directory"
log_info ""
log_info "Asimov will run daily to automatically exclude new dependency directories."