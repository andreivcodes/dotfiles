#!/bin/bash

# Main entry point for dotfiles setup
# This script orchestrates the complete macOS development environment setup

set -euo pipefail

# Change to the script's directory
cd "$(dirname "$0")"

# macOS guard
source lib/utils.sh
require_macos

# Execute the main setup script
exec bash installers/all.sh
