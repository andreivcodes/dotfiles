#!/bin/bash

set -euo pipefail

# Source utility functions
source "$(dirname "$0")/../lib/utils.sh"

log_info "Starting Dock configuration..."

# Ensure not running as sudo
check_not_sudo

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
DOCK_APPS=(
  "/System/Applications/Launchpad.app"
  "/Applications/Safari.app"
  "/System/Applications/Messages.app"
  "/Applications/WhatsApp.app"
  "/System/Applications/Mail.app"
  "/Applications/Slack.app"
  "/Applications/Discord.app"
  "/Applications/Telegram.app"
  "/Applications/Signal.app"
  "/System/Applications/Calendar.app"
  "/Applications/Zed.app"
  "/System/Applications/Utilities/Terminal.app"
  "/Applications/GitHub Desktop.app"
  "/Applications/Beekeeper Studio.app"
  "/System/Applications/App Store.app"
  "/System/Applications/System Settings.app"
  "/Applications/Brave Browser.app"
)

# Add applications to Dock
log_info "Adding applications to Dock..."
total=${#DOCK_APPS[@]}
current=0
failed_apps=()

for app_path in "${DOCK_APPS[@]}"; do
  current=$((current + 1))
  app_name=$(basename "$app_path" .app)
  show_progress $current $total "Adding $app_name"
  
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

# Summary
if [ ${#failed_apps[@]} -eq 0 ]; then
  log_success "Dock configuration completed successfully!"
  log_info "Added ${#DOCK_APPS[@]} applications to Dock"
else
  log_warning "Dock configuration completed with some failures:"
  for app in "${failed_apps[@]}"; do
    log_error "  Failed: $(basename "$app")"
  done
fi
