# Repository Guidelines

## Project Structure & Module Organization
- `setup`: Main entry point. Runs full macOS setup.
- `installers/`: Install steps (`brew.sh`, `dev.sh`, `dock.sh`, `timemachine-exclude.sh`). Example: `bash installers/all.sh`.
- `preferences/`: macOS defaults and system tweaks (`preferences/system.sh`).
- `dotfiles/`: Configs and symlink logic (`dotfiles/dotfiles.sh`, `.zshrc`, `zed/`).
- `lib/`: Shared helpers (`lib/utils.sh` for logging, guards, symlinks).
- `Brewfile`: Packages for `brew bundle`.

## Build, Test, and Development Commands
- Run everything: `./setup` — orchestrates all installers with macOS guard.
- Install Homebrew + apps: `bash installers/brew.sh` (uses `Brewfile`). Optional: `INSTALL_CLAUDE=1 bash installers/brew.sh`.
- Dev toolchain (NVM/Node, Rust): `bash installers/dev.sh`.
- macOS preferences: `bash preferences/system.sh`.
- Dotfiles symlinks: `bash dotfiles/dotfiles.sh`.

## Coding Style & Naming Conventions
- Language: Bash with `set -euo pipefail` and helper functions from `lib/utils.sh`.
- Indentation: 2 spaces, LF endings, trim whitespace (.editorconfig).
- Naming: scripts end with `.sh`, functions `snake_case`, user‑facing scripts in `installers/` and `preferences/`.
- Patterns: idempotent scripts, no `sudo` unless required; use `check_not_sudo`, `require_macos`, `safe_symlink`.

## Testing Guidelines
- Lint: `shellcheck installers/*.sh preferences/*.sh dotfiles/*.sh lib/*.sh`.
- Syntax: `bash -n <script>` before running.
- Dry run: confirm prompts allow safe cancellation; test modules individually (see commands above).
- Scope: avoid destructive changes; verify backups when touching files (see `backup_if_exists`).

## Commit & Pull Request Guidelines
- Commits: concise, imperative summary (optionally Conventional Commits). Examples: `feat: add Time Machine exclusions`, `fix: handle brew upgrade errors`.
- PRs: include purpose, scope, manual test notes (commands run, macOS version), and risks/rollback. Link issues if any. Screenshots only when UI/UX (Dock layout) changes.

## Security & Configuration Tips
- macOS only: scripts guard with `require_macos`.
- Never run full setup with `sudo`; use least privilege. Some steps elevate internally where needed.
- Secrets: this repo stores configs only; avoid embedding tokens. Use environment files outside VCS.

