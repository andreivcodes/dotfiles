#!/bin/bash

set -euo pipefail

# Source utility functions
source "$(dirname "$0")/../lib/utils.sh"

log_info "Starting Dock configuration..."

# Ensure not running as sudo
check_not_sudo
require_macos

# Resolve the current macOS app launcher path. Launchpad was replaced by Apps
# on newer macOS releases, so prefer whichever launcher the system ships.
get_launcher_app() {
  if [ -d "/System/Applications/Apps.app" ]; then
    printf '%s\n' "/System/Applications/Apps.app"
    return 0
  fi

  if [ -d "/System/Applications/Launchpad.app" ]; then
    printf '%s\n' "/System/Applications/Launchpad.app"
    return 0
  fi

  return 1
}

# Function to add an application to the Dock
add_app_to_dock() {
  local app_path="$1"

  # Check if the application path exists
  if [ ! -e "$app_path" ]; then
    log_error "Application path does not exist: $app_path"
    return 1
  fi

  # Add application to the Dock configuration
  if defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$app_path</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"; then
    log_success "Added $(basename "$app_path" .app) to Dock"
    return 0
  else
    log_error "Failed to add $app_path to Dock"
    return 1
  fi
}

# Clear the Dock
log_info "Clearing current Dock configuration..."
if defaults write com.apple.dock persistent-apps -array; then
  log_success "Dock cleared"
else
  log_error "Failed to clear Dock"
  exit 1
fi

# Define applications to add to Dock
# Order: finder, launcher (added via dockutil), safari, messages, whatsapp, mail,
#        slack, discord, telegram, calendar, zed preview, claude, t3 code,
#        terminal, github, tableplus, app store, settings, notion, figma,
#        google chrome
# Note: the macOS app launcher is added separately using dockutil.
DOCK_APPS=(
  "/System/Library/CoreServices/Finder.app"
  "/Applications/Safari.app"
  "/System/Applications/Messages.app"
  "/Applications/WhatsApp.app"
  "/System/Applications/Mail.app"
  "/Applications/Slack.app"
  "/Applications/Discord.app"
  "/Applications/Telegram.app"
  "/System/Applications/Calendar.app"
  "/Applications/Zed Preview.app"
  "/Applications/Claude.app"
  "/Applications/T3 Code (Alpha).app"
  "/System/Applications/Utilities/Terminal.app"
  "/Applications/GitHub Desktop.app"
  "/Applications/TablePlus.app"
  "/System/Applications/App Store.app"
  "/System/Applications/System Settings.app"
  "/Applications/Notion.app"
  "/Applications/Figma.app"
  "/Applications/Google Chrome.app"
)

LAUNCHER_APP=""
LAUNCHER_NAME=""
if LAUNCHER_APP=$(get_launcher_app); then
  LAUNCHER_NAME=$(basename "$LAUNCHER_APP" .app)
fi

# Add applications to Dock
log_info "Adding applications to Dock..."
total=${#DOCK_APPS[@]}
current=0
failed_apps=()

for app_path in "${DOCK_APPS[@]}"; do
  current=$((current + 1))
  app_name=$(basename "$app_path" .app)
  show_progress "$current" "$total" "Adding $app_name"

  if ! add_app_to_dock "$app_path"; then
    failed_apps+=("$app_path")
  fi
done

# Restart the Dock to apply changes
log_info "Restarting Dock to apply changes..."
if killall Dock; then
  log_success "Dock restarted successfully"
else
  log_warning "Failed to restart Dock, changes may not be visible immediately"
fi

# Add the macOS app launcher using dockutil (special case - doesn't work with defaults write)
log_info "Adding app launcher to Dock using dockutil..."
if [ -z "$LAUNCHER_APP" ]; then
  log_warning "No macOS app launcher app found. Skipping launcher item."
elif command_exists dockutil; then
  # Wait for Dock to fully restart
  sleep 2

  # Add the launcher at position 2 (after Finder)
  if dockutil --add "$LAUNCHER_APP" --position 2 --no-restart 2>/dev/null; then
    log_success "Added $LAUNCHER_NAME to Dock"
    # Restart Dock again to show the launcher
    killall Dock 2>/dev/null || true
  else
    log_warning "Failed to add $LAUNCHER_NAME to Dock"
  fi
else
  log_warning "dockutil not installed - skipping app launcher (install with: brew install dockutil)"
fi

# Summary
if [ ${#failed_apps[@]} -eq 0 ]; then
  log_success "Dock configuration completed successfully!"
  if [ -n "$LAUNCHER_NAME" ]; then
    log_info "Added ${#DOCK_APPS[@]} applications to Dock (plus $LAUNCHER_NAME)"
  else
    log_info "Added ${#DOCK_APPS[@]} applications to Dock"
  fi
else
  log_warning "Dock configuration completed with some failures:"
  for app in "${failed_apps[@]}"; do
    log_error "  Failed: $(basename "$app")"
  done
fi
