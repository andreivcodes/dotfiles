#!/bin/bash

set -euo pipefail

# Function to add an application to the Dock
add_app_to_dock() {
  local app_path="$1"

  # Check if the application path exists
  if [ ! -e "$app_path" ]; then
    echo "Error: Application path '$app_path' does not exist."
    return 1
  fi

  # Add application to the Dock configuration
  defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$app_path</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"

  echo "Added '$app_path' to the Dock."
}

# Clear the Dock
echo "Clearing the Dock..."
defaults write com.apple.dock persistent-apps -array

# Add specified applications to the Dock
echo "Adding applications to the Dock..."

add_app_to_dock "/System/Applications/Launchpad.app"
add_app_to_dock "/Applications/Safari.app"

add_app_to_dock "/System/Applications/Messages.app"
add_app_to_dock "/Applications/WhatsApp.app"
add_app_to_dock "/System/Applications/Mail.app"
add_app_to_dock "/Applications/Slack.app"
add_app_to_dock "/Applications/Discord.app"
add_app_to_dock "/Applications/Telegram.app"

add_app_to_dock "/Applications/Obsidian.app"
add_app_to_dock "/System/Applications/Calendar.app"

add_app_to_dock "/Applications/Ghostty.app"
add_app_to_dock "/Applications/Zed Preview.app"
add_app_to_dock "/Applications/GitHub Desktop.app"
add_app_to_dock "/Applications/TablePlus.app"

add_app_to_dock "/System/Applications/App Store.app"
add_app_to_dock "/System/Applications/System Settings.app"
add_app_to_dock "/Applications/Brave Browser.app"

# Restart the Dock to apply changes
echo "Restarting the Dock..."
killall Dock

echo "Dock configuration completed."
