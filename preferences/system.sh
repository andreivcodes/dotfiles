#!/bin/bash

set -euo pipefail

# Source utility functions
source "$(dirname "$0")/../lib/utils.sh"

log_info "Starting macOS system preferences configuration..."

# Ensure not running as sudo
check_not_sudo

# Close System Preferences to prevent conflicts
log_info "Closing System Preferences to prevent conflicts..."
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

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Show the ~/Library folder
chflags nohidden ~/Library

# Show the /Volumes folder
sudo chflags nohidden /Volumes 2>/dev/null || true

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
sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "Property of Andrei Voinea" || true

# Screenshots
log_info "Configuring Screenshot preferences..."

# Save screenshots to ~/Screenshots
mkdir -p ~/Screenshots
defaults write com.apple.screencapture location -string "~/Screenshots"

# Save screenshots in PNG format
defaults write com.apple.screencapture type -string "png"

# Disable screenshot shadows
defaults write com.apple.screencapture disable-shadow -bool true

# Energy Preferences
log_info "Configuring Energy preferences..."

# Never go into computer sleep mode while plugged in
sudo pmset -c sleep 0 || true

# Set display sleep to 15 minutes while plugged in
sudo pmset -c displaysleep 15 || true

# Other Preferences
log_info "Configuring other system preferences..."

# Disable .DS_Store file creation on network and USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" " || true

# Increase window resize speed
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# Disable automatic termination of inactive apps
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Display Configuration
log_info "Configuring display scaling..."
if command -v displayplacer >/dev/null 2>&1; then
    # Get the display ID
    DISPLAY_ID=$(displayplacer list | grep "Persistent screen id:" | head -1 | awk '{print $4}')
    if [ -n "$DISPLAY_ID" ]; then
        # Set to More Space (1800x1169 at 120Hz, usually mode 66 on MacBook Pro 14")
        # This provides more screen real estate
        displayplacer "id:$DISPLAY_ID res:1800x1169 hz:120 color_depth:8 enabled:true scaling:on origin:(0,0) degree:0" 2>/dev/null || \
        displayplacer "id:$DISPLAY_ID mode:66" 2>/dev/null || \
        log_warning "Could not set display to More Space mode"
        log_success "Display set to More Space mode"
    else
        log_warning "Could not detect display ID"
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

log_success "System preferences configuration completed successfully!"
log_info "Note: Some changes may require a logout/restart to take full effect."
