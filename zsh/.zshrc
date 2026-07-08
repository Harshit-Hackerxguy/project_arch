# =============================================================================
# File: zsh/.zshrc
# Description: Main interactive configuration for Zsh.
# Layer: Layer 4 — Developer Environment
# =============================================================================

# Exit if not running interactively
[[ $- != *i* ]] && return

# -----------------------------------------------------------------------------
# History Configuration
# -----------------------------------------------------------------------------
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
HISTSIZE=50000
SAVEHIST=50000

setopt EXTENDED_HISTORY          # Record timestamps
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first
setopt HIST_IGNORE_DUPS          # Ignore consecutive duplicates
setopt HIST_IGNORE_ALL_DUPS      # Remove older duplicates when adding new ones
setopt HIST_FIND_NO_DUPS         # Do not display duplicates in search
setopt HIST_IGNORE_SPACE         # Do not record commands beginning with space
setopt HIST_SAVE_NO_DUPS         # Do not write duplicate entries to history file
setopt HIST_VERIFY               # Don't execute immediately upon history expansion
setopt SHARE_HISTORY             # Share history across running sessions

# -----------------------------------------------------------------------------
# Zsh Options & Quality-of-Life
# -----------------------------------------------------------------------------
setopt AUTO_CD                   # Jump to directory by typing its name
setopt AUTO_PUSHD                # Push directory to stack on cd
setopt PUSHD_IGNORE_DUPS         # Do not store duplicate directories in stack
setopt PUSHD_SILENT              # Do not print directory stack after pushd/popd
setopt CORRECT                   # Spelling correction for commands
setopt INTERACTIVE_COMMENTS      # Allow comments in interactive shell
setopt NO_BEEP                   # Disable terminal beep
setopt PROMPT_SUBST              # Allow parameter expansion in prompts

# -----------------------------------------------------------------------------
# Key Bindings (Vi / Emacs Hybrid with standard navigation)
# -----------------------------------------------------------------------------
bindkey -e
bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^W' backward-kill-word
bindkey '^U' backward-kill-line

# -----------------------------------------------------------------------------
# Completion System
# -----------------------------------------------------------------------------
autoload -Uz compinit
mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
compinit -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' rehash true
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{cyan}-- %d --%f'
zstyle ':completion:*:messages' format '%F{purple}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------
# eza (modern ls replacement)
if command -v eza &>/dev/null; then
    alias ls='eza --group-directories-first --icons'
    alias ll='eza --long --group-directories-first --icons --git'
    alias la='eza --long --all --group-directories-first --icons --git'
    alias lt='eza --tree --level=2 --icons'
else
    alias ls='ls --color=auto --group-directories-first'
    alias ll='ls -lh'
    alias la='ls -lah'
fi

# bat (modern cat replacement)
if command -v bat &>/dev/null; then
    alias cat='bat --paging=never'
fi

# ripgrep & fd
alias grep='rg'
alias find='fd'

# Safe file operations
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# Git shortcuts
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'

# System maintenance
alias update='sudo pacman -Syu'
alias cleanup='sudo pacman -Sc'
alias ports='ss -tulnp'
alias df='duf'
alias du='dust'
alias top='btop'
alias ps='procs'

# Clipboard integration helper
if command -v wl-copy &>/dev/null; then
    alias c='wl-copy'
    alias p='wl-paste'
fi

# -----------------------------------------------------------------------------
# External Tools & Integrations
# -----------------------------------------------------------------------------
# fzf fuzzy finder
if command -v fzf &>/dev/null; then
    source <(fzf --zsh 2>/dev/null || true)
    export FZF_DEFAULT_OPTS="--height=40% --layout=reverse --border=rounded --prompt='❯ ' --pointer='▶' --marker='✓' --color=bg+:#1E293B,bg:#0B0F14,spinner:#38BDF8,hl:#8B5CF6 --color=fg:#E5E7EB,header:#8B5CF6,info:#94A3B8,pointer:#38BDF8 --color=marker:#10B981,fg+:#E5E7EB,prompt:#38BDF8,hl+:#38BDF8"
    if command -v fd &>/dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
    fi
fi

# zoxide smarter cd
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi

# Starship prompt
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

# -----------------------------------------------------------------------------
# Startup Display (Fastfetch on fresh login session)
# -----------------------------------------------------------------------------
if [[ -z "${TMUX}" && -z "${TERMINAL_WELCOME_SHOWN}" ]]; then
    export TERMINAL_WELCOME_SHOWN=1
    if command -v fastfetch &>/dev/null; then
        fastfetch
    fi
fi
