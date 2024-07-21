source $HOME/.zprofile

# node
volta setup
volta install node
volta install yarn
volta install npm

source $HOME/.zprofile
source $HOME/.zshrc

npm install -g npm-check-updates

# rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

. "$HOME/.cargo/env"

cargo install cargo-autoinherit
cargo install cargo-upgrades
cargo install cargo-edit
