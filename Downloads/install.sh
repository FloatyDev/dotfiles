#!/bin/bash
# =============================================================================
# Dotfiles Install Script
# Run this AFTER cloning your dotfiles repo:
#
#   git clone git@github.com:FloatyDev/dotfiles.git ~/dotfiles
#   cd ~/dotfiles && bash install.sh
#
# Options:
#   --dry-run     Preview all actions without making any changes
#   --no-deps     Skip apt package installation
#   --no-nvim     Skip Neovim installation
#   --help        Show this message
# =============================================================================

set -euo pipefail
IFS=$'\n\t'

# ─── Config ───────────────────────────────────────────────────────────────────
DOTFILES_REPO="git@github.com:FloatyDev/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"
LOG_FILE="/tmp/dotfiles_install_$(date +%Y%m%d_%H%M%S).log"

# Always resolves to the latest stable release automatically
NVIM_RELEASE_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage"
NVIM_BIN="$HOME/.local/bin/nvim"

# ─── Flags ────────────────────────────────────────────────────────────────────
DRY_RUN=false
INSTALL_DEPS=true
INSTALL_NVIM=true
_SHIM_CREATED=0

if ! command -v sudo &>/dev/null; then
    if [ "$(id -u)" -eq 0 ]; then
        printf '#!/bin/sh\nexec "$@"\n' > /usr/local/bin/sudo
        chmod +x /usr/local/bin/sudo
        _SHIM_CREATED=1
    else
        echo "[ERROR] No sudo and not root."
        exit 1
    fi
fi

for arg in "$@"; do
    case $arg in
        --dry-run)  DRY_RUN=true ;;
        --no-deps)  INSTALL_DEPS=false ;;
        --no-nvim)  INSTALL_NVIM=false ;;
        --help)
            sed -n '3,12p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *)
            echo "Unknown option: $arg  (use --help)"
            exit 1
            ;;
    esac
done

# ─── Colors ───────────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
    CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'
else
    RED=''; GREEN=''; YELLOW=''; CYAN=''; BOLD=''; RESET=''
fi

# ─── Logging ──────────────────────────────────────────────────────────────────
log()     { echo -e "${CYAN}[INFO]${RESET}  $*" | tee -a "$LOG_FILE"; }
ok()      { echo -e "${GREEN}[ OK ]${RESET}  $*" | tee -a "$LOG_FILE"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*" | tee -a "$LOG_FILE"; }
error()   { echo -e "${RED}[ERR ]${RESET}  $*" | tee -a "$LOG_FILE" >&2; }
section() { echo -e "\n${BOLD}${CYAN}── $* ──${RESET}\n" | tee -a "$LOG_FILE"; }

run() {
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}[DRY ]${RESET}  $*" | tee -a "$LOG_FILE"
    else
        "$@" >> "$LOG_FILE" 2>&1
    fi
}

# ─── Error trap ───────────────────────────────────────────────────────────────
on_error() {
    error "Failed at line $1. Last 5 log lines:"
    tail -5 "$LOG_FILE" >&2
    error "Full log: $LOG_FILE"
    exit 1
}
trap 'on_error $LINENO' ERR

# ─── Helpers ──────────────────────────────────────────────────────────────────
command_exists() { command -v "$1" &>/dev/null; }

confirm() {
    [[ "$DRY_RUN" == true ]] && return 0
    read -r -p "$(echo -e "${YELLOW}  $1 [y/N]${RESET} ")" resp
    [[ "${resp,,}" == "y" || "${resp,,}" == "yes" ]]
}

safe_backup() {
    local src="$1"
    [[ -e "$src" || -L "$src" ]] || return 0
    local rel="${src#"$HOME"/}"
    local dest="$BACKUP_DIR/$rel"
    run mkdir -p "$(dirname "$dest")"
    run mv "$src" "$dest"
    warn "Backed up: ~/$rel  →  $BACKUP_DIR/$rel"
}

dotfiles() {
    /usr/bin/git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" "$@"
}

# ─── Guard: must run from inside the cloned repo ──────────────────────────────
assert_in_repo() {
    section "Checking environment"

    local script_dir
    script_dir="$(cd "$(dirname "$0")" && pwd)"

    if ! git -C "$script_dir" rev-parse --is-inside-work-tree &>/dev/null; then
        error "This script must be run from inside the cloned dotfiles repo."
        error "  git clone $DOTFILES_REPO ~/dotfiles"
        error "  cd ~/dotfiles && bash install.sh"
        exit 1
    fi

    for cmd in git curl; do
        if ! command_exists "$cmd"; then
            error "Required command not found: $cmd — install it first."
            exit 1
        fi
    done

    ok "Running from: $script_dir"
}

# ─── System packages ──────────────────────────────────────────────────────────
install_deps() {
    section "System Dependencies"

    if [[ "$INSTALL_DEPS" == false ]]; then
        warn "Skipping (--no-deps)"
        return 0
    fi

    if ! command_exists apt-get; then
        warn "apt-get not found — skipping (non-Debian system)"
        return 0
    fi

    local packages=(
        git curl wget unzip
        ripgrep          # telescope :live_grep
        fd-find          # telescope :find_files
        xclip            # system clipboard support
        nodejs npm       # copilot, mcphub
        python3 python3-pip
        build-essential
    )

    log "Updating apt..."
    run sudo apt-get update -qq

    local to_install=()
    for pkg in "${packages[@]}"; do
        if ! dpkg -s "$pkg" &>/dev/null 2>&1; then
            to_install+=("$pkg")
        fi
    done

    if [[ ${#to_install[@]} -gt 0 ]]; then
        log "Installing: ${to_install[*]}"
        run sudo apt-get install -y "${to_install[@]}"
        ok "Packages installed"
    else
        ok "All packages already present"
    fi

    # Debian/Ubuntu ships fd as 'fdfind' — expose it as 'fd'
    if command_exists fdfind && ! command_exists fd; then
        run mkdir -p "$HOME/.local/bin"
        run ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
        ok "Symlinked fdfind → ~/.local/bin/fd"
    fi
}

# ─── Neovim ───────────────────────────────────────────────────────────────────
install_neovim() {
    section "Neovim"

    if [[ "$INSTALL_NVIM" == false ]]; then
        warn "Skipping (--no-nvim)"
        return 0
    fi

    # Skip if already 0.11+
    if command_exists nvim; then
        local ver major minor
        ver=$(nvim --version 2>/dev/null | head -1 | grep -oP '\d+\.\d+' | head -1 || echo "0.0")
        major=$(echo "$ver" | cut -d. -f1)
        minor=$(echo "$ver" | cut -d. -f2)
        if [[ "$major" -gt 0 || ( "$major" -eq 0 && "$minor" -ge 11 ) ]]; then
            ok "Neovim $ver already installed (>= 0.11) — skipping"
            return 0
        fi
        warn "Found Neovim $ver — upgrading to latest stable (0.11+)"
    fi

    log "Downloading latest stable Neovim..."
    run mkdir -p "$HOME/.local/bin"
    run curl -fLo "$NVIM_BIN" "$NVIM_RELEASE_URL"
    run chmod +x "$NVIM_BIN"

    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        warn "~/.local/bin not in PATH yet — will be fixed after 'source ~/.bashrc'"
    fi

    if [[ "$DRY_RUN" == false ]]; then
        ok "Installed: $("$NVIM_BIN" --version | head -1)"
    else
        ok "Would install Neovim to $NVIM_BIN"
    fi
}

# ─── Bare repo ────────────────────────────────────────────────────────────────
setup_bare_repo() {
    section "Dotfiles Bare Repo"

    if [[ -d "$DOTFILES_DIR" ]]; then
        warn "Bare repo already exists at $DOTFILES_DIR"
        if ! confirm "Re-initialize? (existing bare repo will be removed)"; then
            log "Keeping existing bare repo"
            return 0
        fi
        run rm -rf "$DOTFILES_DIR"
    fi

    log "Cloning bare repo from $DOTFILES_REPO..."
    run git clone --bare "$DOTFILES_REPO" "$DOTFILES_DIR"

    if [[ "$DRY_RUN" == false ]]; then
        dotfiles config --local status.showUntrackedFiles no
    fi

    ok "Bare repo ready at $DOTFILES_DIR"
}

# ─── Checkout ─────────────────────────────────────────────────────────────────
checkout_files() {
    section "Checking Out Config Files"

    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}[DRY ]${RESET}  dotfiles checkout" | tee -a "$LOG_FILE"
        return 0
    fi

    # Detect conflicts first — back them up before overwriting
    local conflicts
    conflicts=$(dotfiles checkout 2>&1 \
        | grep -E "^\s+\." \
        | awk '{print $1}' \
        || true)

    if [[ -n "$conflicts" ]]; then
        warn "Conflicting files found — backing up to $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        while IFS= read -r file; do
            [[ -z "$file" ]] && continue
            safe_backup "$HOME/$file"
        done <<< "$conflicts"
    fi
	# Handle untracked files in the work tree that would block checkout
	local untracked
	untracked=$(dotfiles checkout 2>&1 \
	    | grep "would be overwritten" -A 100 \
	    | grep -E "^\s+" \
	    | awk '{print $1}' || true)
	
	if [[ -n "$untracked" ]]; then
	    warn "Untracked files blocking checkout — backing up:"
	    while IFS= read -r file; do
	        [[ -z "$file" ]] && continue
	        safe_backup "$HOME/$file"
	    done <<< "$untracked"
	fi
    dotfiles checkout --force
    ok "Config files in place"
}

# ─── Post-install ─────────────────────────────────────────────────────────────
post_install() {
    section "Post-Install"

    # Pre-clone lazy.nvim so first nvim open skips the bootstrap delay
    local lazy_path="$HOME/.local/share/nvim/lazy/lazy.nvim"
    if [[ ! -d "$lazy_path" ]]; then
        log "Pre-installing lazy.nvim..."
        run git clone --filter=blob:none \
            https://github.com/folke/lazy.nvim.git \
            --branch=stable "$lazy_path"
        ok "lazy.nvim ready"
    else
        ok "lazy.nvim already present"
    fi

    # Python formatters used by conform.nvim
    if command_exists pip3; then
        log "Installing black + isort..."
        run pip3 install black isort --break-system-packages -q \
            || warn "Python formatter install failed (non-fatal)"
        ok "black + isort installed"
    else
        warn "pip3 not found — skipping Python formatters"
    fi

    # mcp-hub for mcphub.nvim — non-fatal, bundled fallback exists in config
    if command_exists npm; then
        log "Installing mcp-hub..."
        run npm install -g mcp-hub@latest \
            || warn "mcp-hub install failed — mcphub.nvim will fall back to bundled binary"
        ok "mcp-hub installed"
    else
        warn "npm not found — skipping mcp-hub"
    fi
}

# ─── Summary ──────────────────────────────────────────────────────────────────
print_summary() {
    echo ""
    echo -e "${BOLD}${GREEN}  ✓ Setup complete!${RESET}"
    echo ""
    echo -e "  ${BOLD}Next steps:${RESET}"
    echo -e "  1. ${CYAN}source ~/.bashrc${RESET}"
    echo -e "     Reload your shell to pick up PATH and the dotfiles alias."
    echo ""
    echo -e "  2. ${CYAN}nvim${RESET}"
    echo -e "     Lazy.nvim will auto-install all plugins on first open."
    echo ""
    echo -e "  3. Inside nvim: ${CYAN}:MasonUpdate${RESET}"
    echo -e "     Install LSP servers (clangd, pyright, lua_ls, etc.)."
    echo ""
    if [[ -d "$BACKUP_DIR" ]]; then
        echo -e "  ${YELLOW}Backed up conflicting files to:${RESET}"
        echo -e "  ${CYAN}$BACKUP_DIR${RESET}"
        echo ""
    fi
    echo -e "  Full install log: ${CYAN}$LOG_FILE${RESET}"
    echo ""
    echo -e "  ${BOLD}Manage dotfiles going forward:${RESET}"
    echo -e "  ${CYAN}dotfiles status${RESET}"
    echo -e "  ${CYAN}dotfiles add ~/.config/nvim/lua/user/_cc.lua${RESET}"
    echo -e "  ${CYAN}dotfiles commit -m \"feat: update config\"${RESET}"
    echo -e "  ${CYAN}dotfiles push${RESET}"
    echo ""
}

# ─── Main ─────────────────────────────────────────────────────────────────────
main() {
    echo -e "${BOLD}"
    echo "  ┌──────────────────────────────────────┐"
    echo "  │        Dotfiles Bootstrap Setup      │"
    echo "  └──────────────────────────────────────┘"
    echo -e "${RESET}"

    [[ "$DRY_RUN" == true ]] && warn "DRY RUN — no changes will be made\n"
    log "Log file: $LOG_FILE"

    assert_in_repo
    install_deps
    install_neovim
    setup_bare_repo
    checkout_files
    post_install
    print_summary
}

main "$@"

if [ "$_SHIM_CREATED" -eq 1 ]; then
    rm -f /usr/local/bin/sudo
fi
