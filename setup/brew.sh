/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew update
brew upgrade

brew install wget
brew install volta

sleep 1

echo "Success! Basic brew packages are installed."

brew install --cask 1password
brew install --cask discord
brew install --cask obsidian
brew install --cask slack
brew install --cask whatsapp
brew install --cask brave-browser
brew install --cask github
brew install --cask rectangle
brew install --cask topnotch
brew install --cask zed
brew install --cask docker

sleep 1

echo "Success! Brew additional applications are installed."