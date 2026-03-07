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
2. Installs system packages via `apt` (`ripgrep`, `fd`, `xclip`, `nodejs`, `python3`)
3. Downloads the latest stable Neovim (0.11+) to `~/.local/bin/nvim`
4. Clones the bare repo to `~/.dotfiles` with `$HOME` as the work tree
5. Backs up any conflicting files to `~/.dotfiles-backup/<timestamp>/` preserving directory structure
6. Force checks out all config files to their correct locations
7. Creates `~/.bash_local` from `.bash_local.example` for machine-specific config
8. Pre-installs `lazy.nvim`, `black`, `isort`, `mcp-hub`

### Options

```bash
bash install.sh --dry-run    # preview all actions, no changes made
bash install.sh --no-deps    # skip apt packages
bash install.sh --no-nvim    # skip Neovim download
```

### After install

```bash
# 1. Add your machine-specific config
vim ~/.bash_local             # uncomment what you need: conda, pyenv, SSH aliases, API keys

# 2. Reload shell
source ~/.bashrc

# 3. Open Neovim — plugins install automatically
nvim

# 4. Inside nvim — install LSP servers
:MasonUpdate
```

---

## Machine-specific config

`.bashrc` is fully portable — it contains no usernames, IPs, or secrets.

Machine-specific config lives in `~/.bash_local` which is sourced by `.bashrc`
but is **never committed to this repo**. A template is provided:

```bash
cp ~/.bash_local.example ~/.bash_local
# then edit ~/.bash_local and uncomment what you need
```

Put here: SSH aliases, VPN aliases, conda init, pyenv, CUDA exports, API keys.

---

## How the bare repo works

The bare repo's work tree is `$HOME`. Files are tracked at their real paths —
no symlinks, no moves.

The `dotfiles` alias works exactly like `git`:

```bash
dotfiles status
dotfiles add ~/.config/nvim/lua/user/_cc.lua
dotfiles commit -m "feat: update codecompanion"
dotfiles push
dotfiles pull
```

Track a new file:
```bash
dotfiles add ~/.config/nvim/lua/user/newfile.lua
dotfiles commit -m "feat: add newfile"
dotfiles push
```

---

## Neovim

Plugins are managed by [lazy.nvim](https://github.com/folke/lazy.nvim) and
install automatically on first launch.

| Category | Plugins |
|---|---|
| LSP | `nvim-lspconfig`, `mason.nvim`, `nvim-navic` |
| Completion | `nvim-cmp`, `copilot.lua` |
| AI | `codecompanion.nvim` (DeepSeek), `mcphub.nvim` |
| Debugging | `nvim-dap`, `nvim-dap-python` |
| Formatting | `conform.nvim` (black, isort, stylua, prettier) |
| Navigation | `telescope.nvim`, `oil.nvim` |
| UI | `lualine.nvim`, `bufferline.nvim`, `gitsigns.nvim`, `dashboard-nvim` |

Run `:MasonUpdate` on first launch to install LSP servers:
`clangd`, `lua_ls`, `pyright`, `bashls`, `jsonls`, `jdtls`

All paths in the Neovim config resolve via `vim.fn.stdpath()` and
`vim.fn.exepath()` — no hardcoded usernames or absolute paths anywhere.

---

## Requirements

- `git` and `curl` available before running the script
- GitHub SSH key configured for the `git@github.com` remote
- Debian/Ubuntu for `apt` installs (use `--no-deps` on other distros)
