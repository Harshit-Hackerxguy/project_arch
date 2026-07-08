#!/usr/bin/env bash
# =============================================================================
# Script Name: shell.sh
# Description: Configures the base shell environment for the user account.
#              This script:
#                - Writes XDG environment variables to ~/.bash_profile
#                - Sets default applications (EDITOR, BROWSER, PAGER)
#                - Configures Wayland-specific environment variables that
#                  Layer 2 will depend on
#                - Configures basic interactive shell settings in ~/.bashrc
#                - Does NOT configure Zsh (that is Layer 4)
#                - Does NOT configure any GUI application
#
# Usage:       bash install/shell.sh
#              (or called from install.sh — preferred)
#
# Environment: Reads shared variables from variables.sh (auto-sourced).
# Requires:    directories.sh must have been run first.
#
# Author:      project_arch contributors
# Layer:       Layer 1 — Base System
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/variables.sh"

# =============================================================================
# Constants
# =============================================================================

# The files we will modify. We back up both before writing.
readonly BASH_PROFILE="${HOME}/.bash_profile"
readonly BASHRC="${HOME}/.bashrc"

# A sentinel comment that marks the start of our configuration block.
# We check for this string before writing to avoid appending duplicates.
readonly PA_MARKER="# >>> project_arch configuration >>>"
readonly PA_MARKER_END="# <<< project_arch configuration <<<"

# =============================================================================
# Environment Variable Blocks
# =============================================================================
# These heredocs define the content written to ~/.bash_profile and ~/.bashrc.
# Using heredocs keeps the content readable and avoids escaping issues.

# The content written to ~/.bash_profile.
# ~/.bash_profile is sourced by login shells (e.g., when you log in at a TTY
# or via SSH). It is the correct place for environment variables because:
#   1. It runs once per login session
#   2. Variables set here are inherited by all child processes (GUI apps, etc.)
#   3. Interactive shell configs (.bashrc) are NOT sourced by login shells
#      unless .bash_profile explicitly sources .bashrc
bash_profile_block() {
    cat <<'PROFILE_EOF'

# >>> project_arch configuration >>>
# Written by: install/shell.sh
# Layer: Layer 1 — Base System
# Do not edit this block manually — it may be overwritten by the installer.
# To override these settings, add your changes AFTER the project_arch block.

# -----------------------------------------------------------------------------
# Source .bashrc for interactive settings
# bash_profile is for login shells; .bashrc is for interactive shells.
# Many systems only source one or the other. We explicitly source .bashrc here
# so that aliases and functions are available in login shells too.
# -----------------------------------------------------------------------------
[[ -f "${HOME}/.bashrc" ]] && source "${HOME}/.bashrc"

# -----------------------------------------------------------------------------
# XDG Base Directory Specification
# Setting these variables ensures that applications which follow the XDG spec
# will store their files in the correct locations rather than cluttering HOME.
# See: https://specifications.freedesktop.org/basedir-spec/latest/
# -----------------------------------------------------------------------------
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_STATE_HOME="${HOME}/.local/state"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_BIN_HOME="${HOME}/.local/bin"

# Add user binaries to PATH. ~/.local/bin takes precedence over system paths
# so that user-installed tools shadow system versions when needed.
export PATH="${HOME}/.local/bin:${PATH}"

# -----------------------------------------------------------------------------
# Default Applications
# These environment variables tell applications and scripts which program
# to use for editing files, browsing the web, and viewing text.
#
# EDITOR: Used by git, crontab -e, and many CLI tools when opening a file.
# VISUAL: Some programs prefer VISUAL over EDITOR for full-screen editors.
# PAGER: Used by man, git log, and other commands for scrollable output.
# BROWSER: Used by some applications to open URLs.
# -----------------------------------------------------------------------------
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="bat --paging=always"
export BROWSER="firefox"   # Change this when a browser is installed in Layer 6.
export MANPAGER="sh -c 'col -bx | bat -l man -p'"   # Syntax-highlighted man pages via bat.

# -----------------------------------------------------------------------------
# Wayland Environment Variables
# These variables configure the Wayland session. They are set here (in Layer 1)
# rather than in Layer 2 so that any Wayland-aware applications started from
# a login shell (e.g., during testing) behave correctly.
#
# Layer 2 (Hyprland) will set additional Wayland variables in its own
# environment.conf — those take precedence for the Hyprland session.
# -----------------------------------------------------------------------------

# Tell applications to prefer the Wayland backend.
# Qt5/Qt6 applications use this to select the wayland QPA plugin.
export QT_QPA_PLATFORM="wayland;xcb"   # Wayland preferred, X11 fallback.
export QT_QPA_PLATFORMTHEME="qt5ct"    # Qt theming tool — configured in Layer 5.

# Mozilla applications (Firefox, Thunderbird) use this to enable Wayland.
export MOZ_ENABLE_WAYLAND=1

# Electron applications — enables Wayland rendering.
# Some apps override this; it must also be set in their .desktop files.
export ELECTRON_OZONE_PLATFORM_HINT="auto"

# SDL2 applications — prefer Wayland.
export SDL_VIDEODRIVER="wayland"

# Clutter applications — prefer Wayland.
export CLUTTER_BACKEND="wayland"

# Java applications — Wayland support via XWayland for now.
# Set this to 'wayland' if you confirm your Java version supports it.
export _JAVA_AWT_WM_NONREPARENTING=1

# -----------------------------------------------------------------------------
# Locale and Input
# Setting these explicitly prevents locale-related warnings in some apps.
# Adjust LC_ALL to match your actual locale (see: locale -a).
# -----------------------------------------------------------------------------
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# -----------------------------------------------------------------------------
# GPG Agent
# Tell GPG which terminal to use for passphrase prompts.
# Required for git commit signing and pass (password manager).
# -----------------------------------------------------------------------------
export GPG_TTY="$(tty)"

# -----------------------------------------------------------------------------
# Development Shortcuts
# Convenience variables for frequently used development paths.
# These are project_arch conventions — not XDG standard.
# -----------------------------------------------------------------------------
export DEV_HOME="${HOME}/dev"

# <<< project_arch configuration <<<
PROFILE_EOF
}

# The content written to ~/.bashrc.
# ~/.bashrc is sourced by interactive non-login shells (e.g., new terminal
# windows in a GUI, subshells spawned by scripts when interactive).
# This is the right place for:
#   - Aliases
#   - Shell functions for interactive use
#   - PS1 prompt (basic version — full prompt in Layer 4)
#   - fzf keybindings
#   - Tool initialization (zoxide, etc.)
bashrc_block() {
    cat <<'BASHRC_EOF'

# >>> project_arch configuration >>>
# Written by: install/shell.sh
# Layer: Layer 1 — Base System
# Do not edit this block manually — it may be overwritten by the installer.

# Only run this block in interactive shells.
# When bash is invoked non-interactively (e.g., by a script), skip this block.
[[ $- != *i* ]] && return

# -----------------------------------------------------------------------------
# Shell Options
# These options modify how Bash itself behaves.
# -----------------------------------------------------------------------------
shopt -s histappend       # Append to history file instead of overwriting.
shopt -s checkwinsize     # Update LINES and COLUMNS after each command.
shopt -s globstar         # Enable ** glob pattern (recursive matching).
shopt -s cdspell          # Correct minor typos in cd arguments.
shopt -s autocd           # Type a directory name to cd into it.

# -----------------------------------------------------------------------------
# History Configuration
# Better history: large, no duplicates, no whitespace-prefixed commands.
# -----------------------------------------------------------------------------
HISTSIZE=10000            # Number of commands to keep in memory.
HISTFILESIZE=50000        # Number of commands to keep in the history file.
HISTCONTROL=ignoreboth    # ignorespace: don't record commands with leading space
                          # ignoredups: don't record duplicate commands.
HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S  "  # Show timestamps with history.

# -----------------------------------------------------------------------------
# Bash Completion
# Source bash-completion if installed. Provides tab-completion for many tools.
# -----------------------------------------------------------------------------
if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
fi

# -----------------------------------------------------------------------------
# Aliases
# Short names for frequently used commands. Each alias is documented.
# Layer 4 (Zsh) will supersede many of these with Zsh-specific equivalents.
# -----------------------------------------------------------------------------

# eza: modern ls replacement with color and git status
if command -v eza &>/dev/null; then
    alias ls='eza --group-directories-first --icons'
    alias ll='eza --long --group-directories-first --icons --git'
    alias la='eza --long --all --group-directories-first --icons --git'
    alias lt='eza --tree --level=2 --icons'
else
    # Fallback to standard ls with color
    alias ls='ls --color=auto --group-directories-first'
    alias ll='ls -lh'
    alias la='ls -lah'
fi

# bat: modern cat replacement with syntax highlighting
if command -v bat &>/dev/null; then
    alias cat='bat --paging=never'
fi

# ripgrep: fast grep replacement
alias grep='rg'

# Safety aliases: ask for confirmation before destructive operations.
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Navigation shortcuts.
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git shortcuts (more comprehensive git config in Layer 4).
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'

# System maintenance.
alias update='sudo pacman -Syu'
alias cleanup='sudo pacman -Sc'

# Miscellaneous.
alias reload='source ~/.bash_profile && source ~/.bashrc && echo "Shell reloaded."'
alias path='echo "${PATH}" | tr ":" "\n"'    # Show PATH entries one per line.
alias ports='ss -tulnp'                       # Show listening network ports.
alias df='duf'                                # Better disk usage (duf package).
alias du='dust'                               # Better directory usage (dust package).
alias top='btop'                              # Better process viewer (btop package).
alias ps='procs'                              # Better process list (procs package).

# -----------------------------------------------------------------------------
# fzf Integration
# fzf provides fuzzy search for files, command history, and more.
# The key bindings script adds:
#   Ctrl+R — fuzzy search command history
#   Ctrl+T — fuzzy find files
#   Alt+C  — fuzzy cd into a directory
# -----------------------------------------------------------------------------
if [[ -f /usr/share/fzf/key-bindings.bash ]]; then
    source /usr/share/fzf/key-bindings.bash
fi
if [[ -f /usr/share/fzf/completion.bash ]]; then
    source /usr/share/fzf/completion.bash
fi

# Configure fzf appearance (used by both Bash keybindings and fzf CLI).
export FZF_DEFAULT_OPTS="
    --height=40%
    --layout=reverse
    --border=rounded
    --prompt='❯ '
    --pointer='▶'
    --marker='✓'
"

# Use fd (faster find) as the default source for fzf.
# fd respects .gitignore by default, which makes search results cleaner.
if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
fi

# -----------------------------------------------------------------------------
# zoxide Integration
# zoxide is a smarter cd. It learns your most-visited directories and
# lets you jump to them with partial names.
# After setup: `z proj` might jump to ~/dev/personal/project_arch
# -----------------------------------------------------------------------------
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init bash)"
    # 'zi' triggers an interactive fzf selection of recent directories.
fi

# -----------------------------------------------------------------------------
# Basic PS1 Prompt (Layer 1 version)
# A functional prompt showing user, host, and current directory.
# This will be replaced by a Starship or custom prompt in Layer 4.
# The \[ \] around escape codes prevent PS1 length calculation bugs.
# -----------------------------------------------------------------------------
_pa_git_branch() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return
    printf " (%s)" "${branch}"
}

PS1='\[\e[0;32m\]\u\[\e[0m\]@\[\e[0;36m\]\h\[\e[0m\]:\[\e[0;34m\]\w\[\e[0;33m\]$(_pa_git_branch)\[\e[0m\]\$ '

# <<< project_arch configuration <<<
BASHRC_EOF
}

# =============================================================================
# Configuration Application Functions
# =============================================================================

# has_pa_config — returns 0 if the project_arch marker exists in the file.
# Arguments:
#   $1 — file path to check
has_pa_config() {
    grep -q "${PA_MARKER}" "${1}" 2>/dev/null
}

# write_bash_profile — writes the environment variable configuration to
# ~/.bash_profile. Creates the file if it does not exist.
write_bash_profile() {
    log_info "Configuring ${BASH_PROFILE}..."

    # Back up the existing file before modifying it.
    backup_file "${BASH_PROFILE}"

    # Touch the file to ensure it exists before appending.
    touch "${BASH_PROFILE}"

    if has_pa_config "${BASH_PROFILE}"; then
        log_warn "project_arch configuration already present in ${BASH_PROFILE}."
        log_warn "Skipping to avoid duplicate entries."
        log_warn "To update, remove the block between the >>> markers and re-run."
        return 0
    fi

    # Append the configuration block to the file.
    bash_profile_block >> "${BASH_PROFILE}"
    log_ok "Environment variables written to ${BASH_PROFILE}."
}

# write_bashrc — writes the interactive shell configuration to ~/.bashrc.
write_bashrc() {
    log_info "Configuring ${BASHRC}..."

    backup_file "${BASHRC}"
    touch "${BASHRC}"

    if has_pa_config "${BASHRC}"; then
        log_warn "project_arch configuration already present in ${BASHRC}."
        log_warn "Skipping to avoid duplicate entries."
        return 0
    fi

    bashrc_block >> "${BASHRC}"
    log_ok "Interactive shell configuration written to ${BASHRC}."
}

# write_environment_d — writes persistent environment variables to
# ~/.config/environment.d/project_arch.conf.
# systemd reads files in environment.d at login, making variables available
# to all user services (including the graphical session started by a display
# manager in Layer 2).
#
# This is the most reliable way to ensure Wayland variables are available
# to GUI applications launched by systemd user services.
write_environment_d() {
    local env_file="${XDG_CONFIG_HOME}/environment.d/project_arch.conf"

    log_info "Writing systemd environment.d configuration..."

    mkdir -p "${XDG_CONFIG_HOME}/environment.d"

    if [[ -f "${env_file}" ]]; then
        log_warn "${env_file} already exists — skipping."
        return 0
    fi

    cat > "${env_file}" <<'ENV_EOF'
# ~/.config/environment.d/project_arch.conf
# Written by: install/shell.sh — project_arch Layer 1
#
# This file is read by systemd-environment.d at user session startup.
# Variables set here are available to all user services, including the
# graphical session (Hyprland) when it is started by a display manager.
#
# Format: KEY=VALUE (no export keyword, no quoting needed for simple values)
# See: man environment.d

# XDG Base Directories
XDG_CONFIG_HOME=$HOME/.config
XDG_DATA_HOME=$HOME/.local/share
XDG_STATE_HOME=$HOME/.local/state
XDG_CACHE_HOME=$HOME/.cache

# Default applications
EDITOR=nvim
VISUAL=nvim

# Wayland backend preferences
QT_QPA_PLATFORM=wayland;xcb
MOZ_ENABLE_WAYLAND=1
ELECTRON_OZONE_PLATFORM_HINT=auto
SDL_VIDEODRIVER=wayland
CLUTTER_BACKEND=wayland
_JAVA_AWT_WM_NONREPARENTING=1

# Locale
LANG=en_US.UTF-8
ENV_EOF

    log_ok "systemd environment.d configuration written to ${env_file}."
}

# =============================================================================
# Main
# =============================================================================

main() {
    log_section "Layer 1 — Shell Environment Configuration"

    write_bash_profile
    write_bashrc
    write_environment_d

    log_section "Shell Configuration Complete"
    log_ok "Shell environment configured."
    log_warn "You must start a new login shell (log out and back in)"
    log_warn "for environment variables to take effect."
    log_info "Next step: bash install/verify.sh"
}

main "$@"
