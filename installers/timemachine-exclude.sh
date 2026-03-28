#!/bin/bash

set -euo pipefail

# Source utility functions
# shellcheck disable=SC1091
source "$(dirname "$0")/../lib/utils.sh"

log_info "Starting Time Machine exclusion setup..."

# Ensure not running as sudo
check_not_sudo
require_macos

# Ensure Homebrew is in PATH
# shellcheck source=/dev/null
source "$HOME/.zprofile" 2>/dev/null || true

REPO_ROOT="$(cd "$(dirname "$0")/.." >/dev/null 2>&1 && pwd -P)"
CONFIG_SOURCE="$REPO_ROOT/dotfiles/asimeow/config.yaml"
CONFIG_TARGET="$HOME/.config/asimeow/config.yaml"
BREW_SERVICE_FORMULA="mdnmdn/asimeow/asimeow"
LAUNCH_DOMAIN="gui/$(id -u)"
LEGACY_LABELS=(
    "local.timemachine-exclusions"
    "local.asimov"
)
CACHE_EXCLUSIONS=()

remove_launch_agent() {
    local label=$1
    local target="$LAUNCH_DOMAIN/$label"
    local plist="$HOME/Library/LaunchAgents/$label.plist"

    if launchctl print "$target" >/dev/null 2>&1; then
        launchctl bootout "$target" 2>/dev/null || true
    fi

    rm -f "$plist"
}

exclude_existing_path() {
    local path=$1

    if [ ! -e "$path" ]; then
        mkdir -p "$path" 2>/dev/null || true
    fi

    if [ ! -e "$path" ]; then
        log_info "Skipping unavailable cache path: $path"
        return 0
    fi

    if tmutil addexclusion "$path" >/dev/null 2>&1; then
        log_success "Registered cache exclusion: $path"
    else
        log_warning "Could not register cache exclusion: $path"
    fi
}

add_cache_exclusion() {
    local path=$1
    local existing_path=""

    if [ "${#CACHE_EXCLUSIONS[@]}" -gt 0 ]; then
        for existing_path in "${CACHE_EXCLUSIONS[@]}"; do
            if [ "$existing_path" = "$path" ]; then
                return 0
            fi
        done
    fi

    CACHE_EXCLUSIONS+=("$path")
}

resolve_pnpm_cache() {
    local pnpm_store_path=""
    local pnpm_store_root=""

    if ! command -v pnpm >/dev/null 2>&1; then
        add_cache_exclusion "$HOME/.pnpm-store"
        return 0
    fi

    pnpm_store_path="$(pnpm store path 2>/dev/null | tail -n 1 | tr -d '\r')"

    if [ -z "$pnpm_store_path" ]; then
        add_cache_exclusion "$HOME/.pnpm-store"
        return 0
    fi

    case "$(basename "$pnpm_store_path")" in
        v[0-9]*)
            pnpm_store_root="$(dirname "$pnpm_store_path")"
            add_cache_exclusion "$pnpm_store_root"
            ;;
        *)
            add_cache_exclusion "$pnpm_store_path"
            ;;
    esac
}

resolve_npm_cache() {
    local npm_cache_path=""

    if command -v npm >/dev/null 2>&1; then
        npm_cache_path="$(npm config get cache 2>/dev/null | tail -n 1 | tr -d '\r')"
    fi

    if [ -n "$npm_cache_path" ] && [ "$npm_cache_path" != "undefined" ]; then
        add_cache_exclusion "$npm_cache_path"
    else
        add_cache_exclusion "$HOME/.npm"
    fi
}

resolve_bun_cache() {
    if [ -n "${BUN_INSTALL_CACHE_DIR:-}" ]; then
        add_cache_exclusion "$BUN_INSTALL_CACHE_DIR"
        return 0
    fi

    add_cache_exclusion "$HOME/.bun/install/cache"
}

resolve_cargo_cache() {
    local cargo_home="${CARGO_HOME:-$HOME/.cargo}"

    add_cache_exclusion "$cargo_home/registry"
    add_cache_exclusion "$cargo_home/git"
}

resolve_go_cache() {
    local go_cache_path=""
    local go_mod_cache_path=""

    if ! command -v go >/dev/null 2>&1; then
        return 0
    fi

    go_cache_path="$(go env GOCACHE 2>/dev/null | tail -n 1 | tr -d '\r')"
    go_mod_cache_path="$(go env GOMODCACHE 2>/dev/null | tail -n 1 | tr -d '\r')"

    [ -n "$go_cache_path" ] && add_cache_exclusion "$go_cache_path"
    [ -n "$go_mod_cache_path" ] && add_cache_exclusion "$go_mod_cache_path"
}

resolve_gradle_cache() {
    if [ -d "$HOME/.gradle" ] || command -v gradle >/dev/null 2>&1; then
        add_cache_exclusion "$HOME/.gradle/caches"
        add_cache_exclusion "$HOME/.gradle/wrapper/dists"
    fi
}

resolve_maven_cache() {
    if [ -d "$HOME/.m2" ] || command -v mvn >/dev/null 2>&1; then
        add_cache_exclusion "$HOME/.m2/repository"
    fi
}

resolve_python_cache() {
    add_cache_exclusion "$HOME/.cache/pip"

    if command -v uv >/dev/null 2>&1 || [ -d "$HOME/.cache/uv" ]; then
        add_cache_exclusion "$HOME/.cache/uv"
    fi
}

resolve_yarn_cache() {
    local yarn_cache_path=""

    if ! command -v yarn >/dev/null 2>&1; then
        return 0
    fi

    yarn_cache_path="$(yarn cache dir 2>/dev/null | tail -n 1 | tr -d '\r')"

    if [ -n "$yarn_cache_path" ]; then
        add_cache_exclusion "$yarn_cache_path"
    else
        add_cache_exclusion "$HOME/Library/Caches/Yarn"
    fi
}

collect_cache_exclusions() {
    add_cache_exclusion "$HOME/Library/Caches"

    resolve_npm_cache
    resolve_pnpm_cache
    resolve_bun_cache
    resolve_cargo_cache
    resolve_go_cache
    resolve_gradle_cache
    resolve_maven_cache
    resolve_python_cache
    resolve_yarn_cache
}

if [ ! -f "$CONFIG_SOURCE" ]; then
    log_error "Asimeow config not found: $CONFIG_SOURCE"
    exit 1
fi

mkdir -p "$(dirname "$CONFIG_TARGET")"

if [ ! -L "$CONFIG_TARGET" ] || [ "$(readlink "$CONFIG_TARGET")" != "$CONFIG_SOURCE" ]; then
    if safe_symlink "$CONFIG_SOURCE" "$CONFIG_TARGET"; then
        log_success "Installed Asimeow config"
    else
        log_error "Failed to install Asimeow config"
        exit 1
    fi
fi

if ! command -v asimeow >/dev/null 2>&1; then
    log_error "Asimeow is not available in PATH"
    log_error "Run 'bash installers/brew.sh' first so Homebrew installs the mdnmdn/asimeow tap."
    exit 1
fi

log_info "Removing legacy Time Machine exclusion jobs..."
for label in "${LEGACY_LABELS[@]}"; do
    remove_launch_agent "$label"
done

if command -v brew >/dev/null 2>&1; then
    brew services stop asimov >/dev/null 2>&1 || true
fi

log_info "Registering cache exclusions..."
collect_cache_exclusions
for path in "${CACHE_EXCLUSIONS[@]}"; do
    exclude_existing_path "$path"
done

log_info "Running Asimeow with the dotfiles-managed config..."
if asimeow -c "$CONFIG_TARGET"; then
    log_success "Asimeow exclusion pass completed"
else
    log_error "Asimeow exclusion pass failed"
    exit 1
fi

log_info "Starting the native Asimeow Homebrew service..."
if brew services restart "$BREW_SERVICE_FORMULA"; then
    log_success "Asimeow service is running"
else
    log_error "Failed to start the Asimeow service"
    exit 1
fi

log_success "Time Machine exclusion setup completed!"
log_info "Managed config: $CONFIG_TARGET"
log_info "Asimeow now scans the configured roots every 6 hours via brew services."
log_info "Edit dotfiles/asimeow/config.yaml if you want to add more roots or rules."
