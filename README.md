# Scalyz Terminal Starter

One‑command setup for a clean, productive terminal used on Scalyz Labs, Works on Linux/macOS:

- tmux with copy/paste + CPU/MEM + `scalyz.com` brand bar
- Zsh + Oh My Zsh using the Scalyz theme (git/k8s/venv/SSH context)

## Quick start

```bash
# Clone and run
git clone https://github.com/sclayz-community/scalyz-terminal-starter.git
cd scalyz-terminal-starter
./install.sh
```

**Options** (env vars):

- `BRAND_NAME` (default: `scalyz.com`)
- `BRAND_COLOR` (default: `#407EC9`)

Example:

```bash
BRAND_NAME=scalyz.io BRAND_COLOR=#2F6CC3 ./install.sh
```

## What it does

- Installs (or uses) zsh, tmux, git, curl (via apt/dnf/apk/brew)
- Installs Oh My Zsh (unattended) if missing
- Places `tmux.conf` to `~/.tmux.conf` (backs up old as `.bak`)
- Adds the `scalyz` theme and appends safe defaults to `~/.zshrc`

## Uninstall (manual)

- Remove lines added to `~/.zshrc` (look for `# >>> scalyz-terminal-starter >>>` block)
- Delete `~/.oh-my-zsh/custom/themes/scalyz.zsh-theme` if you don't want the theme
- Restore your previous `~/.tmux.conf.bak` if created

## License

MIT — see [`LICENSE`](LICENSE).
