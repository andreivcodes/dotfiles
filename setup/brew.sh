/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo 'eval $(/opt/homebrew/bin/brew shellenv)' >> $HOME/.zprofile

source $HOME/.zprofile

brew update
brew upgrade

brew install wget
brew install volta
brew install nixpacks

source $HOME/.zprofile

sleep 1

echo "Success! Brew packages are installed."

brew install --cask discord
brew install --cask slack
brew install --cask whatsapp
brew install --cask telegram

brew install --cask obsidian

brew install --cask zed
brew install --cask github
brew install --cask docker
brew install --cask tableplus
brew install --cask brave-browser
brew install --cask ghostty

brew install --cask wifiman
brew install --cask 1password
brew install --cask 1password-cli
brew install --cask macs-fan-control
brew install --cask topnotch

brew install --cask tailscale
brew install --cask zerotier-one

sleep 1

echo "Success! Brew additional applications are installed."
