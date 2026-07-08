#!/usr/bin/env bash
# =============================================================================
# Script Name: directories.sh
# Description: Creates all standard and project-specific directories required
#              by this desktop environment. Running this script is idempotent —
#              directories that already exist are skipped without error.
#
#              Directories are created before shell.sh so that the shell
#              configuration can safely reference these paths.
#
# Usage:       bash install/directories.sh
#              (or called from install.sh — preferred)
#
# Environment: Reads shared variables from variables.sh (auto-sourced).
#
# Author:      project_arch contributors
# Layer:       Layer 1 — Base System
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/variables.sh"

# =============================================================================
# Directory Definitions
# =============================================================================
# Each group of directories is declared as an array.
# mkdir -p is used throughout — it creates parent directories as needed
# and does not error if the directory already exists. This makes the
# script safely re-runnable.

# -----------------------------------------------------------------------------
# XDG Base Directories
# The XDG Base Directory Specification defines standard locations for
# configuration, data, cache, and state files. Applications that follow
# the spec will use these locations automatically when the corresponding
# environment variables are set (done in shell.sh).
#
# References:
#   https://specifications.freedesktop.org/basedir-spec/latest/
# -----------------------------------------------------------------------------
readonly XDG_DIRECTORIES=(
    "${XDG_CONFIG_HOME}"          # ~/.config — application configuration files
    "${XDG_DATA_HOME}"            # ~/.local/share — application data files
    "${XDG_STATE_HOME}"           # ~/.local/state — application state (logs, history)
    "${XDG_CACHE_HOME}"           # ~/.cache — non-essential cached data
    "${XDG_BIN_HOME}"             # ~/.local/bin — user-installed executables
)

# -----------------------------------------------------------------------------
# XDG User Directories
# These are the standard "special" directories defined by xdg-user-dirs.
# Most desktop applications look for these directories when presenting
# file chooser dialogs or suggesting save locations.
# They are separate from the base directories above.
# -----------------------------------------------------------------------------
readonly XDG_USER_DIRECTORIES=(
    "${HOME}/Desktop"
    "${HOME}/Downloads"
    "${HOME}/Documents"
    "${HOME}/Music"
    "${HOME}/Pictures"
    "${HOME}/Videos"
    "${HOME}/Templates"
    "${HOME}/Public"
)

# -----------------------------------------------------------------------------
# Application Configuration Directories
# Placeholders for application-specific config directories that will be
# populated in later layers. Creating them now ensures that shell.sh and
# other scripts can safely reference these paths before the apps are configured.
# -----------------------------------------------------------------------------
readonly APP_CONFIG_DIRECTORIES=(
    "${XDG_CONFIG_HOME}/hypr"         # Hyprland — Layer 2
    "${XDG_CONFIG_HOME}/waybar"       # Waybar — Layer 3
    "${XDG_CONFIG_HOME}/rofi"         # Rofi — Layer 3
    "${XDG_CONFIG_HOME}/dunst"        # Dunst — Layer 3
    "${XDG_CONFIG_HOME}/kitty"        # Kitty — Layer 4
    "${XDG_CONFIG_HOME}/nvim"         # Neovim — Layer 4
    "${XDG_CONFIG_HOME}/gtk-3.0"      # GTK 3 — Layer 5
    "${XDG_CONFIG_HOME}/gtk-4.0"      # GTK 4 — Layer 5
    "${XDG_CONFIG_HOME}/environment.d" # systemd environment.d snippets
)

# -----------------------------------------------------------------------------
# Development Workspace
# Standard locations for source code and personal projects.
# These are conventions, not requirements — they can be changed in variables.sh.
# -----------------------------------------------------------------------------
readonly DEV_DIRECTORIES=(
    "${HOME}/dev"                    # Root for all development work
    "${HOME}/dev/personal"           # Personal projects
    "${HOME}/dev/work"               # Work-related projects
    "${HOME}/dev/learning"           # Experimental / learning projects
    "${HOME}/dev/tools"              # Standalone tools and utilities
)

# -----------------------------------------------------------------------------
# Project-Specific Directories
# Directories used by this project itself.
# -----------------------------------------------------------------------------
readonly PROJECT_DIRECTORIES=(
    "${HOME}/.local/share/${PROJECT_NAME}"   # Runtime data for this project
    "${HOME}/.cache/${PROJECT_NAME}"         # Cache directory for this project
    "${HOME}/.local/state/${PROJECT_NAME}"   # State/log directory
)

# -----------------------------------------------------------------------------
# Wallpaper Directory
# Created as a placeholder — actual wallpapers are not committed to the
# repository (see .gitignore). The preview subdirectory is committed.
# -----------------------------------------------------------------------------
readonly WALLPAPER_DIRECTORIES=(
    "${HOME}/Pictures/Wallpapers"           # General wallpaper storage
    "${HOME}/Pictures/Wallpapers/previews"  # Preview thumbnails (committed)
    "${HOME}/Pictures/Screenshots"          # Screenshot save directory
)

# =============================================================================
# Directory Creation Functions
# =============================================================================

# create_directory_group — creates all directories in the given array.
# Reports the result for each directory individually.
# Arguments:
#   $1 — human-readable group name for log output
#   $@ — remaining arguments are directory paths
create_directory_group() {
    local group_name="${1:?create_directory_group: group name required}"
    shift
    local directories=("$@")

    log_info "Creating ${group_name}..."

    local created_count=0
    local skipped_count=0

    for dir in "${directories[@]}"; do
        if [[ -d "${dir}" ]]; then
            # Directory already exists — skip without error (idempotent)
            skipped_count=$(( skipped_count + 1 ))
        else
            mkdir -p "${dir}"
            log_ok "Created: ${dir}"
            created_count=$(( created_count + 1 ))
        fi
    done

    if [[ "${created_count}" -gt 0 ]]; then
        log_ok "${group_name}: ${created_count} created, ${skipped_count} already existed."
    else
        log_info "${group_name}: all directories already exist."
    fi
}

# set_xdg_user_dirs — writes the XDG user-dirs configuration file.
# This file is read by xdg-user-dirs-update and by applications that
# use XDG user directory paths (file managers, etc.).
# The xdg-user-dirs package provides xdg-user-dirs-update.
set_xdg_user_dirs() {
    local user_dirs_conf="${XDG_CONFIG_HOME}/user-dirs.dirs"

    log_info "Writing XDG user-dirs configuration..."

    # Only write if the config does not already exist.
    # If the user has customized their user-dirs, we respect that.
    if [[ -f "${user_dirs_conf}" ]]; then
        log_info "user-dirs.dirs already exists — skipping."
        return 0
    fi

    cat > "${user_dirs_conf}" <<EOF
# XDG User Directories Configuration
# Generated by project_arch Layer 1.
# Managed by: xdg-user-dirs-update
# See: man xdg-user-dirs

XDG_DESKTOP_DIR="\${HOME}/Desktop"
XDG_DOWNLOAD_DIR="\${HOME}/Downloads"
XDG_TEMPLATES_DIR="\${HOME}/Templates"
XDG_PUBLICSHARE_DIR="\${HOME}/Public"
XDG_DOCUMENTS_DIR="\${HOME}/Documents"
XDG_MUSIC_DIR="\${HOME}/Music"
XDG_PICTURES_DIR="\${HOME}/Pictures"
XDG_VIDEOS_DIR="\${HOME}/Videos"
EOF

    log_ok "XDG user-dirs configuration written."

    # If xdg-user-dirs-update is available, run it to apply the config.
    if command_exists xdg-user-dirs-update; then
        xdg-user-dirs-update
        log_ok "xdg-user-dirs-update applied."
    fi
}

# ensure_path_entry — adds ~/.local/bin to PATH in the shell profile
# if it is not already there. This is done here (and in shell.sh) because
# user-installed binaries must be in PATH before they are used.
ensure_bin_in_path() {
    log_info "Ensuring ${XDG_BIN_HOME} is in PATH..."

    # This check reads the current PATH variable, which may not yet include
    # ~/.local/bin if the session predates our shell.sh configuration.
    # We add it to the current session so immediately following steps work.
    if [[ ":${PATH}:" != *":${XDG_BIN_HOME}:"* ]]; then
        export PATH="${XDG_BIN_HOME}:${PATH}"
        log_ok "Added ${XDG_BIN_HOME} to PATH for this session."
    else
        log_info "${XDG_BIN_HOME} is already in PATH."
    fi
}

# =============================================================================
# Main
# =============================================================================

main() {
    log_section "Layer 1 — Directory Setup"

    create_directory_group "XDG Base Directories"          "${XDG_DIRECTORIES[@]}"
    create_directory_group "XDG User Directories"          "${XDG_USER_DIRECTORIES[@]}"
    create_directory_group "Application Config Dirs"       "${APP_CONFIG_DIRECTORIES[@]}"
    create_directory_group "Development Workspace"         "${DEV_DIRECTORIES[@]}"
    create_directory_group "Project Directories"           "${PROJECT_DIRECTORIES[@]}"
    create_directory_group "Wallpaper and Media Dirs"      "${WALLPAPER_DIRECTORIES[@]}"

    set_xdg_user_dirs
    ensure_bin_in_path

    log_section "Directory Setup Complete"
    log_ok "All directories are in place."
    log_info "Next step: bash install/shell.sh"
}

main "$@"
