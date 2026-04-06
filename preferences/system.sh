#!/bin/bash

set -euo pipefail

# Source utility functions
source "$(dirname "$0")/../lib/utils.sh"

log_info "Starting macOS system preferences configuration..."

# Ensure not running as sudo
check_not_sudo
require_macos

# Ensure Homebrew is in PATH (needed for displayplacer)
# shellcheck source=/dev/null
source "$HOME/.zprofile" 2>/dev/null || true

SUDO_AVAILABLE=false
PRIVILEGED_APPLIED=()
PRIVILEGED_SKIPPED=()
PRIVILEGED_FAILED=()

if sudo -n true 2>/dev/null; then
    SUDO_AVAILABLE=true
elif [ -t 0 ] && [ -t 1 ]; then
    log_info "Some settings require administrator access."
    if sudo -v; then
        SUDO_AVAILABLE=true
        log_success "Administrator access granted"
    else
        log_warning "Administrator access not granted. Privileged settings will be skipped."
    fi
else
    log_warning "No interactive sudo session available. Privileged settings will be skipped."
fi

run_privileged_setting() {
    local label=$1
    shift

    if [ "$SUDO_AVAILABLE" != true ]; then
        PRIVILEGED_SKIPPED+=("$label")
        log_warning "Skipped: $label (sudo unavailable)"
        return 0
    fi

    if sudo "$@"; then
        PRIVILEGED_APPLIED+=("$label")
        log_success "Applied: $label"
    else
        PRIVILEGED_FAILED+=("$label")
        log_warning "Failed: $label"
    fi

    return 0
}

# Close Settings apps to prevent conflicts across older and newer macOS releases.
log_info "Closing System Settings to prevent conflicts..."
osascript -e 'tell application "System Settings" to quit' 2>/dev/null || true
osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true

# Finder Preferences
log_info "Configuring Finder preferences..."

# Use current Finder settings - keep your existing preferences
# Set new window target to home folder
defaults write com.apple.finder NewWindowTarget -string "PfHm"

# Don't show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool false

# Show external hard drives on desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true

# Show removable media on desktop
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Don't show internal hard drives on desktop
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false

# Show sidebar
defaults write com.apple.finder ShowSidebar -bool true

# Set sidebar width
defaults write com.apple.finder SidebarWidth -int 128

# Enable devices section in sidebar
defaults write com.apple.finder SidebarDevicesSectionDisclosedState -bool true

# Enable places section in sidebar
defaults write com.apple.finder SidebarPlacesSectionDisclosedState -bool true

# Hide tags from Finder sidebar
defaults write com.apple.finder ShowRecentTags -bool false

# Create git folder if it doesn't exist
log_info "Ensuring git folder exists..."
if [ ! -d "$HOME/git" ]; then
    mkdir -p "$HOME/git"
    log_success "Created git folder at $HOME/git"
else
    log_info "Git folder already exists at $HOME/git"
fi

# Configure Finder Sidebar Favorites
log_info "Preparing folders for Finder sidebar..."

# Open folders in Finder to make them accessible
# Note: macOS removed programmatic sidebar management in recent versions
# Users need to manually add folders using Cmd+Ctrl+T or drag & drop
open "$HOME" 2>/dev/null || true
open "$HOME/git" 2>/dev/null || true

log_success "Folders opened in Finder"
log_info "To add to sidebar: Select each folder and press Cmd+Ctrl+T"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Show the ~/Library folder
chflags nohidden ~/Library

# Show the /Volumes folder
run_privileged_setting "Show /Volumes folder" chflags nohidden /Volumes

# Dock Preferences
log_info "Configuring Dock preferences..."

# Set Dock icon size to smaller (36 pixels, about half the default)
defaults write com.apple.dock tilesize -int 36

# Disable auto-hide for the Dock (keep it visible)
defaults write com.apple.dock autohide -bool false

# Disable magnification (no zoom effect on icons)
defaults write com.apple.dock magnification -bool false

# Position Dock on the bottom
defaults write com.apple.dock orientation -string "bottom"

# Don't show recent applications in Dock
defaults write com.apple.dock show-recents -bool false

# Trackpad Preferences
log_info "Configuring Trackpad preferences..."

# Enable tap to click for current user and login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Enable three finger drag
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

# Keyboard Preferences
log_info "Configuring Keyboard preferences..."

# Enable full keyboard access for all controls (Tab between form controls)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Set a fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Security & Privacy
log_info "Configuring Security & Privacy preferences..."

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Show a message when the screen is locked
run_privileged_setting "Set lock screen message" defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "Property of Andrei Voinea"

# Screenshots
log_info "Configuring Screenshot preferences..."

# Save screenshots to ~/Screenshots
mkdir -p ~/Screenshots
defaults write com.apple.screencapture location -string "$HOME/Screenshots"

# Save screenshots in PNG format
defaults write com.apple.screencapture type -string "png"

# Disable screenshot shadows
defaults write com.apple.screencapture disable-shadow -bool true

# Energy Preferences
log_info "Configuring Energy preferences..."

# Never go into computer sleep mode while plugged in
run_privileged_setting "Disable AC sleep" pmset -c sleep 0

# Set display sleep to 15 minutes while plugged in
run_privileged_setting "Set AC display sleep to 15 minutes" pmset -c displaysleep 15

# Other Preferences
log_info "Configuring other system preferences..."

# Disable .DS_Store file creation on network and USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Disable the sound effects on boot
run_privileged_setting "Disable boot sound effects" nvram SystemAudioVolume=" "

# Increase window resize speed
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# Disable automatic termination of inactive apps
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Display Configuration
log_info "Configuring display scaling..."
if command -v displayplacer >/dev/null 2>&1; then
    DISPLAYPLACER_INFO=$(displayplacer list 2>/dev/null || true)
    DISPLAY_COUNT=$(printf '%s\n' "$DISPLAYPLACER_INFO" | awk '/^Persistent screen id:/ {count++} END {print count + 0}')
    DISPLAY_CONFIG=$(printf '%s\n' "$DISPLAYPLACER_INFO" | awk '
        /^Persistent screen id:/ {
            if (id != "") {
                printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", id, type, res, hz, depth, scaling, origin, degree
            }
            id = $4
            type = res = hz = depth = scaling = origin = degree = ""
            next
        }
        /^Type:/ {
            type = substr($0, 7)
            next
        }
        /^Resolution:/ {
            res = $2
            next
        }
        /^Hertz:/ {
            hz = $2
            next
        }
        /^Color Depth:/ {
            depth = $3
            next
        }
        /^Scaling:/ {
            scaling = $2
            next
        }
        /^Origin:/ {
            origin = $2
            gsub(/[()]/, "", origin)
            next
        }
        /^Rotation:/ {
            degree = $2
            next
        }
        END {
            if (id != "") {
                printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", id, type, res, hz, depth, scaling, origin, degree
            }
        }
    ')
    PRIMARY_ID=$(printf '%s\n' "$DISPLAY_CONFIG" | awk -F '\t' '$2 != "MacBook built in screen" { print $1; exit }')
    PRIMARY_ORIGIN=$(printf '%s\n' "$DISPLAY_CONFIG" | awk -F '\t' '$2 != "MacBook built in screen" { print $7; exit }')
    INTERNAL_ID=$(printf '%s\n' "$DISPLAY_CONFIG" | awk -F '\t' '$2 == "MacBook built in screen" { print $1; exit }')

    # Preserve the current resolution and scaling for every display. When an
    # external display is connected, shift origins so the first external
    # display becomes primary. Otherwise leave the built-in display as-is.
    if [ "$DISPLAY_COUNT" -gt 1 ] && [ -n "$PRIMARY_ID" ] && [ -n "$PRIMARY_ORIGIN" ]; then
        PRIMARY_X=${PRIMARY_ORIGIN%%,*}
        PRIMARY_Y=${PRIMARY_ORIGIN##*,}
        DISPLAY_ARGS=()
        while IFS= read -r display_arg; do
            [ -n "$display_arg" ] && DISPLAY_ARGS+=("$display_arg")
        done < <(printf '%s\n' "$DISPLAY_CONFIG" | awk -F '\t' -v primary_x="$PRIMARY_X" -v primary_y="$PRIMARY_Y" '
            {
                split($7, coords, ",")
                shifted_x = coords[1] - primary_x
                shifted_y = coords[2] - primary_y
                printf "id:%s res:%s hz:%s color_depth:%s scaling:%s origin:(%d,%d) degree:%s\n",
                    $1, $3, $4, $5, $6, shifted_x, shifted_y, $8
            }
        ')

        if [ "${#DISPLAY_ARGS[@]}" -gt 0 ] && displayplacer "${DISPLAY_ARGS[@]}" 2>/dev/null; then
            log_success "External display set as the primary display"
        else
            log_warning "Could not update display arrangement"
        fi
    elif [ "$DISPLAY_COUNT" -eq 1 ] && [ -n "$INTERNAL_ID" ]; then
        log_info "Single built-in display detected. Leaving current scaling unchanged."
    else
        log_info "No external display detected. Leaving current display arrangement unchanged."
    fi
else
    log_warning "displayplacer not installed. Display scaling not configured."
fi

# Rectangle Window Management Configuration
log_info "Configuring Rectangle window management..."
if [ -d "/Applications/Rectangle.app" ]; then
    # Set Rectangle to launch at login
    defaults write com.knollsoft.Rectangle launchOnLogin -bool true
    
    # Hide menu bar icon for cleaner look
    defaults write com.knollsoft.Rectangle hideMenubarIcon -bool false
    
    # Enable snap areas (drag windows to edges)
    defaults write com.knollsoft.Rectangle snapEdges -int 1
    
    # Set gap between windows (in pixels)
    defaults write com.knollsoft.Rectangle gapSize -float 10
    
    # Enable automatic window snapping
    defaults write com.knollsoft.Rectangle allowAnyShortcutWithOptionModifier -bool true
    
    # Configure default keyboard shortcuts
    defaults write com.knollsoft.Rectangle leftHalf -dict keyCode 123 modifierFlags 786432  # Ctrl+Opt+Left
    defaults write com.knollsoft.Rectangle rightHalf -dict keyCode 124 modifierFlags 786432  # Ctrl+Opt+Right
    defaults write com.knollsoft.Rectangle maximize -dict keyCode 126 modifierFlags 786432  # Ctrl+Opt+Up
    defaults write com.knollsoft.Rectangle restore -dict keyCode 125 modifierFlags 786432  # Ctrl+Opt+Down
    defaults write com.knollsoft.Rectangle topLeft -dict keyCode 123 modifierFlags 917504  # Ctrl+Opt+Cmd+Left
    defaults write com.knollsoft.Rectangle topRight -dict keyCode 124 modifierFlags 917504  # Ctrl+Opt+Cmd+Right
    defaults write com.knollsoft.Rectangle bottomLeft -dict keyCode 123 modifierFlags 1048576  # Cmd+Left
    defaults write com.knollsoft.Rectangle bottomRight -dict keyCode 124 modifierFlags 1048576  # Cmd+Right
    defaults write com.knollsoft.Rectangle center -dict keyCode 8 modifierFlags 786432  # Ctrl+Opt+C
    
    log_success "Rectangle configured successfully"
else
    log_info "Rectangle not installed yet. Will be configured after installation."
fi

# Restart affected applications
log_info "Restarting affected applications to apply changes..."
if killall Finder && killall Dock && killall SystemUIServer; then
  log_success "Applications restarted successfully"
else
  log_warning "Some applications may not have restarted properly"
fi

if [ ${#PRIVILEGED_APPLIED[@]} -gt 0 ]; then
    log_info "Applied privileged settings: ${PRIVILEGED_APPLIED[*]}"
fi

if [ ${#PRIVILEGED_SKIPPED[@]} -gt 0 ]; then
    log_warning "Skipped privileged settings: ${PRIVILEGED_SKIPPED[*]}"
    log_info "Run 'sudo -v' and rerun this script if you want those settings applied."
fi

if [ ${#PRIVILEGED_FAILED[@]} -gt 0 ]; then
    log_warning "Failed privileged settings: ${PRIVILEGED_FAILED[*]}"
fi

if [ ${#PRIVILEGED_SKIPPED[@]} -eq 0 ] && [ ${#PRIVILEGED_FAILED[@]} -eq 0 ]; then
    log_success "System preferences configuration completed successfully!"
else
    log_warning "System preferences configuration completed with warnings."
fi
log_info "Note: Some changes may require a logout/restart to take full effect."
