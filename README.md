# dotfiles

Personal configuration files for Neovim, tmux, Alacritty, and shell — managed
with a bare git repository so every file lives at its real path with no symlinks.

## What's included

| Path | Purpose |
|---|---|
| `.config/nvim/` | Neovim (lazy.nvim, LSP, DAP, codecompanion, copilot) |
| `.config/alacritty/` | Alacritty terminal |
| `.bashrc` | Portable shell config and aliases |
| `.bash_local.example` | Template for machine-specific config |
| `.tmux.conf` | tmux keybindings and status bar |
| `.gitignore` | Bare repo ignore rules |
| `install.sh` | Bootstrap script |

---

## Fresh install on a new machine

```bash
git clone git@github.com:<you>/dotfiles.git ~/dotfiles
cd ~/dotfiles && bash install.sh
```

### What the script does

1. Reads the repo URL from `git remote get-url origin` — no hardcoded paths
2. Installs system packages via `apt`
3. Downloads the latest stable Neovim (0.11+) to `~/.local/bin/nvim`
4. Clones the bare repo to `~/.dotfiles` with `$HOME` as the work tree
5. Backs up any conflicting files to `~/.dotfiles-backup/<timestamp>/`
6. Force checks out all config files to their correct locations
7. Creates `~/.bash_local` from `.bash_local.example`
8. Pre-installs `lazy.nvim`, `black`, `isort`, `mcp-hub`

### Options

```bash
bash install.sh --dry-run    # preview all actions, no changes made
bash install.sh --no-deps    # skip apt packages
bash install.sh --no-nvim    # skip Neovim download
bash install.sh --https      # use HTTPS instead of SSH (Docker/CI)
```

### After install

```bash
# 1. Add your machine-specific config
vim ~/.bash_local

# 2. Reload shell
source ~/.bashrc

# 3. Open Neovim — plugins install automatically
nvim

# 4. Inside nvim — install LSP servers
:MasonUpdate
```

---

## Machine-specific config

`.bashrc` is fully portable — no usernames, IPs, or secrets.

Machine-specific config lives in `~/.bash_local`, sourced by `.bashrc` but
never committed to this repo. A template is provided:

```bash
cp ~/.bash_local.example ~/.bash_local
# uncomment what you need: conda, pyenv, CUDA, SSH aliases, API keys
```

---

## How the bare repo works

```bash
dotfiles status
dotfiles add ~/.config/nvim/lua/user/_cc.lua
dotfiles commit -m "feat: update config"
dotfiles push / pull
```

---

## Neovim plugins

Managed by [lazy.nvim](https://github.com/folke/lazy.nvim), auto-installs on first launch.
Run `:MasonUpdate` to install LSP servers: `clangd`, `lua_ls`, `pyright`, `bashls`, `jsonls`.

---

## Troubleshooting

### Neovim: `fuse: device not found` (Docker/containers)
AppImages require FUSE which is unavailable in Docker. The install script
handles this automatically by extracting the AppImage instead. If running
manually, use `--no-nvim` and install Neovim separately via your package
manager or build from source.

### mcp-hub: `SyntaxError: Unexpected token '?'`
Your Node.js version is too old — mcp-hub requires Node 14+. Upgrade:
```bash
apt-get remove -y nodejs libnode-dev libnode72 nodejs-doc
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs
npm install -g mcp-hub@latest
```

### `nvim` not found after install
`~/.local/bin` is not in PATH yet. Run `source ~/.bashrc` or open a new
terminal. If it persists, check that `export PATH="$HOME/.local/bin:$PATH"`
is in your `.bashrc`.

### SSH clone fails (Docker/CI)
Use `--https` flag:
```bash
bash install.sh --https
```
Or clone with HTTPS manually before running the script:
```bash
git clone https://github.com/<you>/dotfiles.git ~/dotfiles
```

### Checkout aborted: `untracked files would be overwritten`
The script backs up conflicts automatically and uses `--force`. If you hit
this manually, back up the conflicting files and run:
```bash
/usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" checkout --force
```

### `dotfiles` alias not found after fresh install
```bash
source ~/.bashrc
```
The alias is defined in `.bashrc` and only available after sourcing it.

---

## Requirements

- `git` and `curl` must be available before running the script
- Debian/Ubuntu for `apt` installs (use `--no-deps` on other distros)
- GitHub SSH key configured, or use `--https` for HTTPS cloning
