# dotfiles

Personal configuration files for Neovim, tmux, Alacritty, and shell — managed with a bare git repository so every file lives in its real location with no symlinks.

## What's included

| File | Purpose |
|---|---|
| `.config/nvim/` | Neovim config (lazy.nvim, LSP, DAP, codecompanion) |
| `.config/alacritty/` | Alacritty terminal config |
| `.bashrc` | Shell config, aliases, PATH |
| `.tmux.conf` | tmux keybindings and status bar |

---

## Fresh install on a new machine

```bash
git clone git@github.com:FloatyDev/dotfiles.git ~/dotfiles
cd ~/dotfiles && bash install.sh
```

The script will:

1. Install system packages (`ripgrep`, `fd`, `xclip`, `nodejs`, `python3`)
2. Download the latest stable Neovim (0.11+) to `~/.local/bin/nvim`
3. Clone the bare dotfiles repo to `~/.dotfiles`
4. Back up any files on disk that conflict with the repo to `~/.dotfiles-backup/<timestamp>/`
5. Force checkout all config files to their correct locations in `$HOME`
6. Pre-install `lazy.nvim`, `black`, `isort`, and `mcp-hub`

### Options

```bash
bash install.sh --dry-run    # preview all actions, make no changes
bash install.sh --no-deps    # skip apt package installation
bash install.sh --no-nvim    # skip Neovim download
```

### After install

```bash
source ~/.bashrc             # reload shell
nvim                         # lazy.nvim installs all plugins automatically
# inside nvim:
:MasonUpdate                 # install LSP servers
```

---

## How the bare repo works

The repo's work tree is `$HOME` itself. Files are tracked directly at their real paths — nothing is symlinked or moved.

The `dotfiles` alias (added to `.bashrc` by the install script) is used exactly like `git`:

```bash
dotfiles status
dotfiles add ~/.config/nvim/lua/user/_cc.lua
dotfiles commit -m "feat: update codecompanion config"
dotfiles push
dotfiles pull
```

To start tracking a new file:

```bash
dotfiles add ~/.config/nvim/lua/user/newfile.lua
dotfiles commit -m "feat: add newfile"
dotfiles push
```

---

## Backup behaviour

Before placing any file, the install script asks git which files it intends to write, then backs up every existing file that would be overwritten — preserving the full directory structure under `~/.dotfiles-backup/<timestamp>/`. The checkout then runs with `--force`, safe in the knowledge that nothing has been silently lost.

To restore a backed-up file:

```bash
cp ~/.dotfiles-backup/<timestamp>/.bashrc ~/.bashrc
```

---

## Neovim plugins

Plugins are managed by [lazy.nvim](https://github.com/folke/lazy.nvim) and auto-install on first launch. Notable plugins:

- **LSP** — `nvim-lspconfig`, `mason.nvim`, `nvim-navic`
- **Completion** — `nvim-cmp`, `copilot.lua`
- **AI** — `codecompanion.nvim` with DeepSeek adapter, `mcphub.nvim`
- **Debugging** — `nvim-dap`, `nvim-dap-python`
- **Formatting** — `conform.nvim` (black, isort, stylua, prettier)
- **Navigation** — `telescope.nvim`, `oil.nvim`
- **UI** — `lualine.nvim`, `bufferline.nvim`, `gitsigns.nvim`, `dashboard-nvim`

LSP servers are managed by Mason. After first launch run `:MasonUpdate` to install: `clangd`, `lua_ls`, `pyright`, `bashls`, `jsonls`.

---

## Requirements

- Debian/Ubuntu (the script uses `apt` — skip with `--no-deps` on other distros)
- `git` and `curl` must be available before running the script
- A GitHub SSH key configured for the `git@github.com` remote
