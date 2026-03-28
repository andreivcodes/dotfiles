# Dotfiles

Personal macOS configuration files and development environment setup.

## Quick Start

```bash
git clone https://github.com/andreivcodes/dotfiles.git ~/git/dotfiles
cd ~/git/dotfiles
./setup.sh
```

## What's Included

- **Brewfile**: Declarative package management for Homebrew CLI tools and apps
- **Shell Configuration**: Performance-optimized `.zshrc` with lazy loading
- **AI CLI Configuration**: Shared Codex, Claude Code, and OpenCode setup
- **Shared Agent Rules & Skills**: One canonical instructions file, synced repo skills, and preserved external skill installs
- **Development Environment**: Node.js (via NVM), Rust, Bun, and essential CLI tools
- **Installation Scripts**: Automated setup and symlink management

## Repository Structure

```text
dotfiles/
├── README.md
├── Brewfile
├── setup.sh
├── installers/
│   ├── all.sh
│   ├── ai-tools.sh
│   ├── brew.sh
│   ├── dev.sh
│   ├── dock.sh
│   ├── mcp-env.sh
│   └── timemachine-exclude.sh
├── dotfiles/
│   ├── dotfiles.sh
│   ├── .zshrc
│   ├── agents/
│   │   ├── AGENTS.md
│   │   └── skills/
│   ├── codex/
│   │   └── config.toml
│   ├── claude/
│   │   ├── mcp.json
│   │   ├── settings.json
│   │   └── statusline.sh
│   ├── opencode/
│   │   └── opencode.json
│   └── zed/
│       └── settings.json
├── preferences/
│   └── system.sh
└── lib/
    └── utils.sh
```

## Installation

### Prerequisites

- macOS (tested on macOS 15.2+)
- internet access for Homebrew, npm, git, and installer downloads

### Full Setup (Recommended)

```bash
git clone https://github.com/andreivcodes/dotfiles.git ~/git/dotfiles
cd ~/git/dotfiles
./setup.sh
```

This will:
- Install all Homebrew packages and applications
- Set up Node.js, Bun, and Rust development environments
- Install Codex, Claude Code, OpenCode, Agent Browser, Railway CLI, and Vercel CLI
- Prompt for MCP API keys used by the shared AI tool configs
- Configure macOS system preferences
- Create symlinks for shell, editor, and shared AI CLI configs
- Configure Dock layout
- Set up Time Machine exclusions for development directories

### Partial Setup

```bash
bash installers/brew.sh
bash installers/dev.sh
bash installers/ai-tools.sh
bash installers/mcp-env.sh
bash preferences/system.sh
bash dotfiles/dotfiles.sh
bash installers/dock.sh
bash installers/timemachine-exclude.sh
```

## Key Features

### Shell Configuration

- Lazy loading for `nvm`, `cargo`, and `rustup`
- 100k command history with deduplication and sharing across sessions
- Git aliases for common workflows
- Daily completion cache refresh for faster shell startup
- Minimal Claude wrapper that injects the repo-managed MCP config

### AI CLI Configuration

This repo manages shared config files for the three CLI tools:

- Codex: `~/.codex/config.toml`, `~/.codex/AGENTS.md`
- Claude Code: `~/.claude/settings.json`, `~/.claude/CLAUDE.md`, `~/.claude/mcp.json`, `~/.claude/statusline.sh`
- OpenCode: `~/.config/opencode/opencode.json`, `~/.config/opencode/AGENTS.md`

Usage is plain:

```bash
codex
claude
opencode
```

Authentication is also plain:

```bash
codex login
claude auth login
opencode auth login
```

The repo only manages stable config files and shared skills. Auth, sessions, and other mutable runtime state stay in the tools' native user locations. Any old `~/.codex-profiles`, `~/.claude-profiles`, or `~/.opencode-profiles` directories are no longer used by this repo.

During setup, `installers/mcp-env.sh` prompts for `CONTEXT7_API_KEY` and `EXA_API_KEY` and writes them to `~/.zshrc.local`.

Shared MCP coverage includes `context7`, `gh_grep`, `exa`, `vercel`, and `railway` across Codex, Claude Code, and OpenCode.

### Shared Skills

- Repo skills are linked into the shared skills directory at `~/.agents/skills`
- Skills installed separately, including `skills.sh` symlink installs, are preserved during sync
- Native tool skill directories are linked to that shared location
- One canonical rules file in `dotfiles/agents/AGENTS.md` is linked into each tool's documented shared config location

Because `~/.codex/skills`, `~/.claude/skills`, and `~/.config/opencode/skills` all point at the same shared directory, global `skills.sh` installs done as symlinks stay compatible with this repo's setup.

### Superpowers

This repo tracks the current upstream install pattern for `superpowers` across the supported AI CLIs:

- Claude Code: enabled via `enabledPlugins` as `superpowers@claude-plugins-official`
- OpenCode: added to `plugin` as `superpowers@git+https://github.com/obra/superpowers.git`
- Codex: `installers/ai-tools.sh` clones `obra/superpowers` into `~/.codex/superpowers`, and `dotfiles/dotfiles.sh` links `~/.agents/skills/superpowers` to that checkout so native skill discovery can find it

After syncing dotfiles, restart Claude Code or run `/reload-plugins`, and restart OpenCode so the plugin installs load. For Codex, rerun `bash dotfiles/dotfiles.sh` after `bash installers/ai-tools.sh` if you install or update Superpowers separately.

If you install skills with `skills.sh`, use its recommended symlink mode. This repo is designed to coexist with that layout.

### Brewfile Package Management

Use the checked-in Brewfile directly:

```bash
cd ~/git/dotfiles
brew bundle install
brew bundle check
brew bundle cleanup

brew bundle install --file ~/git/dotfiles/Brewfile
brew bundle check --file ~/git/dotfiles/Brewfile
```

### Zed Configuration

- Codex agent server support
- Prettier formatters for JavaScript, TypeScript, and TSX
- Git gutter and inline blame
- Integrated zsh terminal
- System-aware One Light / One Dark theme

## Performance Testing

### Measure Shell Startup Time

```bash
/usr/bin/time zsh -i -c exit
```

Expected result with the current lazy-loading setup: roughly `0.05-0.15s`.

### Profile Shell Initialization

```bash
zmodload zsh/zprof
exec zsh
zprof
```

## Maintenance

### Updating Packages

```bash
brew update && brew upgrade
omz update

cd ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && git pull
cd ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && git pull
```

### Syncing Changes

The dotfiles are symlinked into your home directory, so edits to managed paths such as `~/.zshrc`, `~/.codex/config.toml`, or `~/.config/zed/` are reflected in the repository.

## Troubleshooting

### Slow Shell Startup

1. Profile the shell with `zprof`
2. Check that `nvm` and `cargo` are still lazy-loaded
3. Trim unused Oh My Zsh plugins
4. Run `brew doctor`

### AI CLIs Not Working

Verify the commands resolve correctly:

```bash
type codex
type claude
type opencode
```

If a tool is missing, install it with:

```bash
brew install --cask codex
curl -fsSL https://claude.ai/install.sh | bash
brew install anomalyco/tap/opencode
brew install railway
npm i -g vercel@latest
```

If Claude is installed but not loading the shared MCP config, reload your shell and verify `~/.claude/mcp.json` exists.

### Completion Not Working

```bash
rm -f ~/.zcompdump
exec zsh
```

### Homebrew Issues

```bash
brew doctor
brew cleanup
brew update
brew upgrade
```

## Security Notes

- `.gitignore` keeps secrets and local-only files out of the repo
- This repo only symlinks stable AI config files; auth and session state stay tool-managed
- `always_allow_tool_actions` in Zed bypasses security prompts; adjust if needed

## Resources

- [Homebrew Documentation](https://docs.brew.sh/)
- [Homebrew Bundle](https://docs.brew.sh/Brew-Bundle-and-Brewfile)
- [Oh My Zsh](https://ohmyz.sh/)
- [Zed Editor](https://zed.dev/)

## License

MIT License. Adjust as needed for your own setup.
