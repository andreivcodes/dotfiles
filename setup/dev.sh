#!/bin/bash

set -euo pipefail

# Ensure shell environment is loaded
source $HOME/.zprofile

# Node.js and npm setup using NVM
echo "Setting up Node.js and npm using NVM..."
if command -v nvm &> /dev/null
then
    echo "NVM is already installed. Setting up Node environment."
    source ~/.nvm/nvm.sh # Load nvm into the current shell
else
    echo "NVM is not installed. Installing..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    source ~/.nvm/nvm.sh # Load nvm into the current shell
    source ~/.zprofile # Ensure profile is reloaded
fi

nvm install node  # Install latest Node.js (includes npm)
nvm use node      # Use latest Node.js
npm install -g yarn # Install yarn globally (optional)
npm install -g npm-check-updates

# Rust setup using rustup (rest of your script remains the same)
echo "Setting up Rust using rustup..."
if command -v rustup &> /dev/null
then
    echo "rustup is already installed. Ensuring Rust environment is configured."
    . "$HOME/.cargo/env"
else
    echo "rustup is not installed. Installing..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    . "$HOME/.cargo/env" # Load rust environment into the current shell
fi

# Install Rust tools
echo "Installing Rust tools..."
cargo install cargo-autoinherit
cargo install cargo-upgrades
cargo install cargo-edit
cargo install cargo-sort
cargo install sea-orm-cli
cargo install cargo-nextest

echo "Success! Development tools are installed and configured."
