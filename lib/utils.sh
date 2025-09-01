#!/bin/bash

# Utility functions for logging and error handling

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# OS guards
require_macos() {
    if [ "$(uname -s)" != "Darwin" ]; then
        log_error "This script is intended to run on macOS (Darwin)."
        exit 1
    fi
}

# Progress indicator
show_progress() {
    local current=$1
    local total=$2
    local task=$3
    local percentage=$((current * 100 / total))
    echo -e "${BLUE}[${current}/${total}]${NC} (${percentage}%) $task"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if application is installed (macOS)
app_exists() {
    [ -d "/Applications/$1" ]
}

# Backup existing file/directory
backup_if_exists() {
    local path=$1
    if [ -L "$path" ] || [ -e "$path" ]; then
        local backup_path="${path}.backup.$(date +%Y%m%d_%H%M%S)"
        log_warning "Backing up existing $path to $backup_path"
        mv "$path" "$backup_path"
        return 0
    fi
    return 1
}

# Safe symlink creation
safe_symlink() {
    local source=$1
    local target=$2
    
    if [ ! -e "$source" ]; then
        log_error "Source file/directory does not exist: $source"
        return 1
    fi
    
    backup_if_exists "$target"
    
    if ln -sf "$source" "$target"; then
        log_success "Created symlink: $target → $source"
        return 0
    else
        log_error "Failed to create symlink: $target → $source"
        return 1
    fi
}

# Check if script is run with sudo when needed
check_sudo() {
    if [ "$EUID" -ne 0 ]; then
        log_error "This script must be run with sudo"
        exit 1
    fi
}

# Ensure script is NOT run with sudo when it shouldn't be
check_not_sudo() {
    if [ "$EUID" -eq 0 ]; then
        log_error "This script should NOT be run with sudo"
        exit 1
    fi
}

# Wait for user confirmation
confirm() {
    local message=${1:-"Do you want to continue?"}
    read -p "$message (y/N): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}
