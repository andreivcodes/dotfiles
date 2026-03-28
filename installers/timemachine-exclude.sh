#!/bin/bash

set -euo pipefail

# Source utility functions
source "$(dirname "$0")/../lib/utils.sh"

log_info "Starting Time Machine exclusion setup..."

# Ensure not running as sudo
check_not_sudo
require_macos

# Ensure Homebrew is in PATH (needed for asimov)
source "$HOME/.zprofile" 2>/dev/null || true

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
    ASIMOV_BIN=$(command -v asimov)

    if asimov; then
        log_success "Asimov completed successfully"
    else
        log_warning "Asimov encountered some issues"
    fi

    # Enable Asimov as a daily service using a user-level LaunchAgent
    # managed through the current launchctl bootstrap workflow.
    log_info "Setting up Asimov daily service..."
    ASIMOV_PLIST="$HOME/Library/LaunchAgents/local.asimov.plist"
    LAUNCH_DOMAIN="gui/$(id -u)"
    SERVICE_LABEL="local.asimov"
    SERVICE_TARGET="$LAUNCH_DOMAIN/$SERVICE_LABEL"
    
    # Create LaunchAgents directory if needed
    mkdir -p "$HOME/Library/LaunchAgents"
    
    # Create or update the LaunchAgent plist
    cat > "$ASIMOV_PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key>
	<string>local.asimov</string>
	<key>ProgramArguments</key>
	<array>
		<string>${ASIMOV_BIN}</string>
	</array>
	<key>StartInterval</key>
	<integer>86400</integer>
	<key>RunAtLoad</key>
	<true/>
	<key>StandardOutPath</key>
	<string>/tmp/asimov.log</string>
	<key>StandardErrorPath</key>
	<string>/tmp/asimov.error.log</string>
</dict>
</plist>
EOF

    # Reload the agent so plist changes take effect on modern macOS.
    if launchctl print "$SERVICE_TARGET" >/dev/null 2>&1; then
        launchctl bootout "$SERVICE_TARGET" 2>/dev/null || true
    fi

    if launchctl bootstrap "$LAUNCH_DOMAIN" "$ASIMOV_PLIST" 2>/dev/null; then
        launchctl enable "$SERVICE_TARGET" 2>/dev/null || true
        launchctl kickstart -k "$SERVICE_TARGET" 2>/dev/null || true
        log_success "Asimov service enabled (runs daily at user login)"
    else
        log_warning "Could not enable Asimov service. You can run 'asimov' manually."
    fi
else
    log_error "Asimov not found. Install with: brew install asimov"
    exit 1
fi

log_success "Time Machine exclusion setup completed!"
log_info "Asimov handles: node_modules, vendor, target, Pods, Carthage, bower_components, .build, stack-work"
log_info "Asimov runs daily to automatically exclude new dependency directories."
