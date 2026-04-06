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
- **AI CLI Configuration**: Shared Codex and Claude Code setup
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
│   ├── asimeow/
│   │   └── config.yaml
│   ├── claude/
│   │   ├── mcp.json
│   │   ├── settings.json
│   │   └── statusline.sh
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
- Install Codex, Claude Code, Claude Desktop, T3 Code, Agent Browser, Railway CLI, and Vercel CLI
- Prompt for MCP API keys used by the shared AI tool configs
- Configure macOS system preferences
- Create symlinks for shell, editor, and shared AI CLI configs
- Configure Dock layout
- Set up Time Machine exclusions for development directories

### Time Machine Exclusions

The dotfiles setup installs `asimeow`, links the repo-managed config to `~/.config/asimeow/config.yaml`, runs an immediate exclusion pass, and then starts the native Homebrew service for ongoing scans.

The managed config intentionally keeps automatic roots outside privacy-protected locations like `~/Desktop`, `~/Documents`, and `~/Downloads`. Background services are less reliable there on modern macOS, so the defaults focus on common unprotected dev roots and keep the scheduled setup predictable.

Defaults are:

- `~/git`
- `~/src`
- `~/code`
- `~/dev`
- `~/work`

User-level dependency caches are also registered directly as exclusions outside the `asimeow` work roots. The installer resolves the actual cache locations where possible and excludes them directly. Examples include:

- `~/Library/Caches`
- npm cache
- pnpm store
- Bun global cache
- Cargo registry and git caches
- Go build and module caches
- pip and `uv` caches
- Gradle caches and wrapper distributions
- Maven local repository
- Yarn cache

To change automatic roots or rules, edit the repo-managed config at `dotfiles/asimeow/config.yaml` and resync dotfiles:

```bash
bash dotfiles/dotfiles.sh
bash installers/timemachine-exclude.sh
```

`asimeow` itself scans on the schedule provided by its Homebrew service, which is currently every 6 hours upstream.

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

This repo manages shared config files for the two CLI tools:

- Codex: `~/.codex/config.toml`, `~/.codex/AGENTS.md`
- Claude Code: `~/.claude/settings.json`, `~/.claude/CLAUDE.md`, `~/.claude/mcp.json`, `~/.claude/statusline.sh`

Usage is plain:

```bash
codex
claude
```

Authentication is also plain:

```bash
codex login
claude auth login
```

The repo only manages stable config files and shared skills. Auth, sessions, and other mutable runtime state stay in the tools' native user locations. Any old `~/.codex-profiles` or `~/.claude-profiles` directories are no longer used by this repo.

During setup, `installers/mcp-env.sh` prompts for `CONTEXT7_API_KEY` and `EXA_API_KEY` and writes them to `~/.zshrc.local`.

Shared MCP coverage includes `context7`, `gh_grep`, `exa`, `vercel`, and `railway` across Codex and Claude Code.

### Shared Skills

- Repo skills are linked into the shared skills directory at `~/.agents/skills`
- Skills installed separately, including `skills.sh` symlink installs, are preserved during sync
- Native tool skill directories are linked to that shared location
- One canonical rules file in `dotfiles/agents/AGENTS.md` is linked into each tool's documented shared config location

Because `~/.codex/skills` and `~/.claude/skills` both point at the same shared directory, global `skills.sh` installs done as symlinks stay compatible with this repo's setup.

### Browser Automation

`agent-browser` is installed through Homebrew on macOS:

```bash
brew install agent-browser
agent-browser install
```

The first command installs the CLI. The second downloads Chrome for Testing, which `agent-browser` uses by default. The repo-managed `agent-browser` skill lives under `dotfiles/agents/skills/agent-browser`, and the shared `AGENTS.md` rules tell Codex and Claude Code to use it for browser automation tasks.

### Superpowers

This repo tracks the current upstream install pattern for `superpowers` across the supported AI CLIs:

- Claude Code: enabled via `enabledPlugins` as `superpowers@claude-plugins-official`
- Codex: `installers/ai-tools.sh` clones `obra/superpowers` into `~/.codex/superpowers`, and `dotfiles/dotfiles.sh` links `~/.agents/skills/superpowers` to that checkout so native skill discovery can find it

After syncing dotfiles, restart Claude Code or run `/reload-plugins`. For Codex, rerun `bash dotfiles/dotfiles.sh` after `bash installers/ai-tools.sh` if you install or update Superpowers separately.

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

### Desktop AI Apps

Full setup also installs:

- Claude Desktop via the official Homebrew `claude` cask
- T3 Code via the official Homebrew `t3-code` cask

The Dock installer places both right after `Zed Preview` when they are installed.

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
type agent-browser
```

If a tool is missing, install it with:

```bash
brew install --cask codex
curl -fsSL https://claude.ai/install.sh | bash
brew install agent-browser
agent-browser install
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
