# ~/.bashrc — portable, profile-agnostic shell config
# Machine-specific config (ssh aliases, VPN, conda, CUDA, API keys)
# belongs in ~/.bash_local which is sourced at the bottom of this file
# and is NEVER committed to the dotfiles repo.

# ─── Non-interactive guard ────────────────────────────────────────────────────
case $- in
    *i*) ;;
      *) return;;
esac

# ─── History ──────────────────────────────────────────────────────────────────
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s histappend
shopt -s checkwinsize

# ─── Less ─────────────────────────────────────────────────────────────────────
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# ─── Prompt ───────────────────────────────────────────────────────────────────
parse_git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

case "$TERM" in
    xterm-color|*-256color) color_prompt=yes ;;
esac

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;31m\]$(parse_git_branch)\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w$(parse_git_branch)\$ '
fi
unset color_prompt

# Set terminal title
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
esac

# ─── Colors ───────────────────────────────────────────────────────────────────
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# ─── Common aliases ───────────────────────────────────────────────────────────
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# ─── PATH — local binaries ────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"

# ─── Dotfiles bare repo alias ─────────────────────────────────────────────────
alias dotfiles='/usr/bin/git --git-dir="$HOME/.dotfiles" --work-tree="$HOME"'

# ─── Bash completion ──────────────────────────────────────────────────────────
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# ─── NVM ──────────────────────────────────────────────────────────────────────
# Guarded — only loads if nvm is actually installed on this machine.
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ]             && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ]    && \. "$NVM_DIR/bash_completion"

# ─── Cargo (Rust) ─────────────────────────────────────────────────────────────
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# ─── Machine-specific config ──────────────────────────────────────────────────
# ~/.bash_local is never committed to the repo.
# Put here: ssh aliases, VPN aliases, conda init, pyenv, CUDA, API keys, etc.
# See ~/.bash_local.example for a template.
[ -f "$HOME/.bash_local" ] && . "$HOME/.bash_local"
