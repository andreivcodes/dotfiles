/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew update
brew upgrade

brew install wget
brew install volta

sleep 1

echo "Success! Brew packages are installed."

brew install --cask discord
brew install --cask obsidian
brew install --cask slack
brew install --cask whatsapp
brew install --cask brave-browser
brew install --cask github
brew install --cask zed@preview
brew install --cask docker
brew install --cask wifiman

sleep 1

echo "Success! Brew additional applications are installed."
