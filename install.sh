#!/bin/bash
# =============================================================================
# Dotfiles Bootstrap Installer
#
# Run this AFTER cloning your dotfiles repo:
#   git clone git@github.com:<YOU>/dotfiles.git ~/dotfiles
#   cd ~/dotfiles && bash install.sh
#
# The repo URL is read from the cloned repo's own remote — no hardcoding.
#
# Options:
#   --dry-run     Preview all actions without making any changes
#   --no-deps     Skip apt package installation
#   --no-nvim     Skip Neovim installation
#   --help        Show this message
# =============================================================================

set -euo pipefail
IFS=$'\n\t'

# ─── Runtime config ───────────────────────────────────────────────────────────
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"
LOG_FILE="/tmp/dotfiles_install_$(date +%Y%m%d_%H%M%S).log"

NVIM_RELEASE_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage"
NVIM_BIN="$HOME/.local/bin/nvim"

# ─── Flags ────────────────────────────────────────────────────────────────────
DRY_RUN=false
INSTALL_DEPS=true
INSTALL_NVIM=true
FORCE_HTTPS=false

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
    mkdir -p "$(dirname "$dest")"
    mv "$src" "$dest"
    warn "Backed up: ~/$rel  →  $BACKUP_DIR/$rel"
}

apt_install() {
    if command_exists sudo; then
        sudo apt-get "$@"
    else
        apt-get "$@"
    fi
}

# Converts SSH remote URL to HTTPS
# git@github.com:user/repo.git  →  https://github.com/user/repo.git
ssh_to_https() {
    echo "$1" | sed 's|git@\(.*\):\(.*\)|https://\1/\2|'
}

dotfiles() {
    /usr/bin/git --git-dir="$DOTFILES_DIR" --work-tree="$HOME" "$@"
}

# ─── Resolve repo URL from the clone we're running inside ────────────────────
# This is the key change from the previous version — no hardcoded GitHub URL.
# The script reads the 'origin' remote from the repo it was cloned from,
# so it works for any fork or any username without modification.
get_repo_url() {
    local script_dir
    script_dir="$(cd "$(dirname "$0")" && pwd)"
    local url
    url=$(git -C "$script_dir" remote get-url origin 2>/dev/null || true)

    if [[ "$FORCE_HTTPS" == true ]]; then
        url=$(ssh_to_https "$url")
    fi

    echo "$url"
}

# ─── Guard: must run from inside the cloned repo ──────────────────────────────
assert_in_repo() {
    section "Checking environment"

    local script_dir
    script_dir="$(cd "$(dirname "$0")" && pwd)"

    if ! git -C "$script_dir" rev-parse --is-inside-work-tree &>/dev/null; then
        error "Must be run from inside the cloned dotfiles repo."
        error "  git clone <your-dotfiles-repo> ~/dotfiles"
        error "  cd ~/dotfiles && bash install.sh"
        exit 1
    fi

    for cmd in git curl; do
        if ! command_exists "$cmd"; then
            error "Required command not found: $cmd"
            exit 1
        fi
    done

    DOTFILES_REPO=$(get_repo_url)

    if [[ -z "$DOTFILES_REPO" ]]; then
        error "Could not determine repo URL from git remote 'origin'."
        error "Make sure the repo has an 'origin' remote configured."
        exit 1
    fi

    ok "Repo URL:    $DOTFILES_REPO"
    ok "Install dir: $DOTFILES_DIR"
    ok "Running as:  $(whoami) @ $(hostname)"
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
        ripgrep
        fd-find
        xclip
        nodejs npm
        python3 python3-pip
        build-essential
    )

    log "Updating apt..."
    run apt_install update -qq

    local to_install=()
    for pkg in "${packages[@]}"; do
        if ! dpkg -s "$pkg" &>/dev/null 2>&1; then
            to_install+=("$pkg")
        fi
    done

    if [[ ${#to_install[@]} -gt 0 ]]; then
        log "Installing: ${to_install[*]}"
		run apt_install install -y "${to_install[@]}"
        ok "Packages installed"
    else
        ok "All packages already present"
    fi

    # Debian/Ubuntu ships fd as 'fdfind'
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

    if command_exists nvim; then
        local ver major minor
        ver=$(nvim --version 2>/dev/null | head -1 | grep -oP '\d+\.\d+' | head -1 || echo "0.0")
        major=$(echo "$ver" | cut -d. -f1)
        minor=$(echo "$ver" | cut -d. -f2)
        if [[ "$major" -gt 0 || ( "$major" -eq 0 && "$minor" -ge 11 ) ]]; then
            ok "Neovim $ver already installed (>= 0.11) — skipping"
            return 0
        fi
        warn "Found Neovim $ver — upgrading to latest stable"
    fi

	local appimage_tmp="/tmp/nvim.appimage"
    local extract_dir="$HOME/.local/share/nvim-appimage"

    log "Downloading latest stable Neovim..."
    mkdir -p "$HOME/.local/bin"
    curl -fLo "$appimage_tmp" "$NVIM_RELEASE_URL" >> "$LOG_FILE" 2>&1
    chmod +x "$appimage_tmp"

    if "$appimage_tmp" --version &>/dev/null 2>&1; then
        # FUSE available — run AppImage directly
        mv "$appimage_tmp" "$NVIM_BIN"
        ok "Installed as AppImage: $("$NVIM_BIN" --version | head -1)"
    else
        # No FUSE (Docker/CI) — extract and wrap
        log "FUSE not available — extracting AppImage..."
        rm -rf "$extract_dir" /tmp/squashfs-root

        # --appimage-extract always creates ./squashfs-root relative to CWD
        # We cd to /tmp, extract there, then move squashfs-root to extract_dir
        # so the final layout is $extract_dir/AppRun (not $extract_dir/squashfs-root/AppRun)
        (cd /tmp && "$appimage_tmp" --appimage-extract >> "$LOG_FILE" 2>&1)

        if [[ ! -f /tmp/squashfs-root/AppRun ]]; then
            error "AppImage extraction failed — AppRun not found in /tmp/squashfs-root"
            exit 1
        fi

        # Move squashfs-root itself to become extract_dir
        mv /tmp/squashfs-root "$extract_dir"
        rm -f "$appimage_tmp"

        cat > "$NVIM_BIN" << WRAPPER
#!/bin/bash
exec "$extract_dir/AppRun" "\$@"
WRAPPER
        chmod +x "$NVIM_BIN"

        local ver
        ver=$("$NVIM_BIN" --version 2>&1 | head -1)
        if echo "$ver" | grep -q "^NVIM"; then
            ok "Installed (extracted): $ver"
        else
            error "Neovim wrapper failed to run: $ver"
            exit 1
        fi
    fi
}

# ─── Bare repo setup ──────────────────────────────────────────────────────────
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
        dotfiles config --local core.excludesFile "$HOME/.gitignore"
    fi

    ok "Bare repo ready at $DOTFILES_DIR"
}

# ─── Backup conflicts & checkout ──────────────────────────────────────────────
checkout_files() {
    section "Backing Up Conflicts & Checking Out"

    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}[DRY ]${RESET}  Would back up conflicts then: dotfiles checkout --force" \
            | tee -a "$LOG_FILE"
        return 0
    fi

    # Collect every file the repo wants to place that already exists on disk.
    # grep catches both git conflict formats with a single pattern.
    local conflicts
    conflicts=$(dotfiles checkout 2>&1 \
        | grep -E "^\s+\S" \
        | awk '{print $1}' \
        || true)

    if [[ -n "$conflicts" ]]; then
        log "Backing up $(echo "$conflicts" | wc -l | tr -d ' ') conflicting file(s) to $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        while IFS= read -r file; do
            [[ -z "$file" ]] && continue
            safe_backup "$HOME/$file"
        done <<< "$conflicts"
        ok "Backup complete → $BACKUP_DIR"
    else
        ok "No conflicting files — clean checkout"
    fi

    # Force checkout — safe because all conflicts have been moved off disk
    dotfiles checkout --force
    ok "Config files checked out to $HOME"
}

# ─── bash_local setup ─────────────────────────────────────────────────────────
setup_bash_local() {
    section "Machine-Specific Shell Config"

    if [[ -f "$HOME/.bash_local" ]]; then
        ok "~/.bash_local already exists — skipping"
        return 0
    fi

    if [[ -f "$HOME/.bash_local.example" ]]; then
        log "Creating ~/.bash_local from template..."
        run cp "$HOME/.bash_local.example" "$HOME/.bash_local"
        ok "~/.bash_local created — edit it to add your machine-specific config"
        warn "Remember to uncomment and fill in: SSH aliases, conda, pyenv, CUDA, API keys"
    else
        warn ".bash_local.example not found — skipping"
    fi
}

# ─── Post-install ─────────────────────────────────────────────────────────────
post_install() {
    section "Post-Install"

    # Pre-clone lazy.nvim so first nvim open skips bootstrap delay
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

    # Python formatters for conform.nvim
    if command_exists pip3; then
        log "Installing black + isort..."
        run pip3 install black isort --break-system-packages -q \
            || warn "Python formatters failed (non-fatal)"
        ok "black + isort installed"
    else
        warn "pip3 not found — skipping Python formatters"
    fi

    # mcp-hub for mcphub.nvim (bundled fallback exists if this fails)
    if command_exists npm; then
        log "Installing mcp-hub..."
        run npm install -g mcp-hub@latest \
            || warn "mcp-hub failed — mcphub.nvim will use bundled binary"
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
    echo -e "  1. Edit ${CYAN}~/.bash_local${RESET} — add your SSH aliases, conda, API keys, etc."
    echo -e "  2. ${CYAN}source ~/.bashrc${RESET} — reload shell"
    echo -e "  3. ${CYAN}nvim${RESET} — lazy.nvim auto-installs all plugins on first open"
    echo -e "  4. Inside nvim: ${CYAN}:MasonUpdate${RESET} — install LSP servers"
    echo ""
    if [[ -d "$BACKUP_DIR" ]]; then
        echo -e "  ${YELLOW}Original files backed up to:${RESET}"
        echo -e "  ${CYAN}$BACKUP_DIR${RESET}"
        echo -e "  Safe to delete once everything looks good."
        echo ""
    fi
    echo -e "  Full install log: ${CYAN}$LOG_FILE${RESET}"
    echo ""
    echo -e "  ${BOLD}Manage dotfiles going forward:${RESET}"
    echo -e "  ${CYAN}dotfiles status${RESET}"
    echo -e "  ${CYAN}dotfiles add <file>${RESET}"
    echo -e "  ${CYAN}dotfiles commit -m \"message\"${RESET}"
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
    setup_bash_local    # ← new: creates ~/.bash_local from template
    post_install
    print_summary
}

main "$@"
