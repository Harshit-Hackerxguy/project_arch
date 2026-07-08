# =============================================================================
# File: zsh/.zshenv
# Description: Environment variables for Zsh sessions (sourced for all shells).
# Layer: Layer 4 — Developer Environment
# =============================================================================

# XDG Base Directory Specification
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_STATE_HOME="${HOME}/.local/state"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_BIN_HOME="${HOME}/.local/bin"

# Ensure user binary paths are prioritized
export PATH="${HOME}/.local/bin:${PATH}"

# Default editors and tools
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="bat --paging=always"
export BROWSER="firefox"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Wayland native environment hints
export QT_QPA_PLATFORM="wayland;xcb"
export QT_QPA_PLATFORMTHEME="qt5ct"
export MOZ_ENABLE_WAYLAND=1
export ELECTRON_OZONE_PLATFORM_HINT="auto"
export SDL_VIDEODRIVER="wayland"
export CLUTTER_BACKEND="wayland"
export _JAVA_AWT_WM_NONREPARENTING=1

# Locale and GPG
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export GPG_TTY="$(tty)"
export DEV_HOME="${HOME}/dev"
