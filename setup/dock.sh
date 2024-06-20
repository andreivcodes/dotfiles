#!/bin/bash

# Function to add an application to the Dock
add_app_to_dock() {
  local app_path="$1"
  defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$app_path</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
}

# Clear the Dock
defaults write com.apple.dock persistent-apps -array

# Add specified applications to the Dock
add_app_to_dock "/System/Applications/Launchpad.app"
add_app_to_dock "/Applications/Safari.app"
#
add_app_to_dock "/System/Applications/Messages.app"
add_app_to_dock "/Applications/WhatsApp.app"
add_app_to_dock "/System/Applications/Mail.app"
add_app_to_dock "/Applications/Slack.app"
add_app_to_dock "/Applications/Discord.app"
#
add_app_to_dock "/Applications/Obsidian.app"
add_app_to_dock "/System/Applications/Calendar.app"
#
add_app_to_dock "/System/Applications/Utilities/Terminal.app"
add_app_to_dock "/Applications/Zed Preview.app"
add_app_to_dock "/Applications/GitHub Desktop.app"
add_app_to_dock "/Applications/TablePlus.app"

add_app_to_dock "/System/Applications/App Store.app"
add_app_to_dock "/System/Applications/System Settings.app"
add_app_to_dock "/Applications/Brave Browser.app"

# Restart the Dock to apply changes
killall Dock
