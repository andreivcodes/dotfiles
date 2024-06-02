# Dotfiles Setup

This repository contains scripts to set up a macOS development environment with essential applications and configurations.

## Repository Structure

- `setup/all.sh`: Main script to execute all setup scripts.
- `setup/brew.sh`: Script to install Homebrew, update it, and install basic packages and applications.
- `setup/dev.sh`: Script to set up development environments for Node.js and Rust.
- `setup/dock.sh`: Script to configure the macOS Dock with specified applications.

## Setup Instructions

### 1. Clone the Repository

First, clone this repository to your local machine:

```bash
git clone https://github.com/andreivcodes/dotfiles.git
cd dotfiles
```

### 2. Make All Scripts Executable

Run the following command to make sure all setup scripts are executable:

```bash
chmod +x setup/all.sh setup/brew.sh setup/dev.sh setup/dock.sh
```

### 3. Run the Main Setup Script

Execute the main setup script to run all individual scripts:

```bash
cd setup
./all.sh
```
