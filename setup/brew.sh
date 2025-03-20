#!/bin/bash

set -euo pipefail

# Check if Homebrew is already installed
if command -v brew &> /dev/null
then
    echo "Homebrew is already installed. Updating and upgrading."
    brew update
    brew upgrade
else
    echo "Homebrew is not installed. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval $(/opt/homebrew/bin/brew shellenv)' >> $HOME/.zprofile
    source $HOME/.zprofile
fi

# Ensure shell environment is loaded for brew
source $HOME/.zprofile

# Install essential brew packages
echo "Installing essential brew packages..."
brew install wget
brew install volta
brew install nixpacks

# Ensure shell environment is loaded again after volta install (it might modify it)
source $HOME/.zprofile

sleep 1 # Sleep to allow shell env changes to propagate

echo "Success! Essential Brew packages are installed."

# Install applications via brew cask
echo "Installing applications via brew cask..."
brew install --cask discord
brew install --cask slack
brew install --cask whatsapp
brew install --cask telegram
brew install --cask zed@preview
brew install --cask github
brew install --cask docker
brew install --cask tableplus
brew install --cask brave-browser
brew install --cask ghostty
brew install --cask wifiman
brew install --cask 1password
brew install --cask 1password-cli
brew install --cask macs-fan-control
brew install --cask tailscale
brew install --cask mullvadvpn

sleep 1 # Sleep after cask installations

echo "Success! Brew additional applications are installed."
