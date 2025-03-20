#!/bin/bash

set -euo pipefail

# Log start of setup
echo "Starting dotfiles setup..."

# Make the scripts executable - no error on failure in case they are already executable
chmod +x brew.sh 2>/dev/null || true
chmod +x dev.sh 2>/dev/null || true
chmod +x dock.sh 2>/dev/null || true
chmod +x browser.sh 2>/dev/null || true # Make browser.sh executable

# Run the scripts
echo "Running brew.sh..."
./brew.sh
echo "Running dev.sh..."
./dev.sh
echo "Running dock.sh..."
./dock.sh

# Log end of setup
echo "Dotfiles setup completed."
