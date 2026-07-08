#!/usr/bin/env bash
# =============================================================================
# Script Name: variables.sh
# Description: Shared constants, configuration variables, and logging utility
#              functions used by all other install/ scripts. This file is
#              sourced, not executed directly.
#
# Usage:       source install/variables.sh
# Environment: No external environment variables required.
#
# Author:      project_arch contributors
# Layer:       Layer 1 — Base System
# =============================================================================
#
# NOTE: This file intentionally does not call `set -euo pipefail`.
#       Strict mode is the responsibility of the calling script.
#       Sourced files should not modify global shell options.

# =============================================================================
# Project Metadata
# =============================================================================

# The canonical name of this project, used in log output and directory names.
readonly PROJECT_NAME="project_arch"

# The current installation layer being applied by the calling script.
# Sourcing scripts may override this before sourcing variables.sh if needed,
# but Layer 1 scripts should not change this value.
readonly INSTALL_LAYER="Layer 1"

# The root of the repository. Resolved relative to this file's location so
# that scripts work correctly regardless of the working directory they are
# called from.
readonly REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# =============================================================================
# Filesystem Paths
# =============================================================================

# The home directory of the user running the installation.
# We use ${HOME} rather than hardcoding a path so scripts work for any user.
readonly USER_HOME="${HOME}"

# XDG Base Directory specification paths.
# These are the standard locations defined in the XDG spec. We set them here
# so that all scripts reference the same values and do not hardcode paths.
# See: https://specifications.freedesktop.org/basedir-spec/latest/
readonly XDG_CONFIG_HOME="${HOME}/.config"
readonly XDG_DATA_HOME="${HOME}/.local/share"
readonly XDG_STATE_HOME="${HOME}/.local/state"
readonly XDG_CACHE_HOME="${HOME}/.cache"
readonly XDG_BIN_HOME="${HOME}/.local/bin"

# The directory where this project's configuration will be installed.
# By default this is the repository root itself (we operate in-place).
readonly CONFIG_INSTALL_DIR="${REPO_ROOT}"

# Backup suffix appended to files before they are modified.
# Example: ~/.bashrc becomes ~/.bashrc.bak
readonly BACKUP_SUFFIX=".bak"

# =============================================================================
# Package Manager Configuration
# =============================================================================

# Pacman flags used for non-interactive installation.
# --noconfirm  — do not ask for confirmation prompts
# --needed     — skip packages that are already installed at the correct version
readonly PACMAN_FLAGS="--noconfirm --needed"

# =============================================================================
# Color Codes for Terminal Output
# =============================================================================
# These codes enable colored output in terminals that support ANSI escape
# sequences. We check if stdout is a terminal before using them so that
# log output is clean when piped to a file.

if [[ -t 1 ]]; then
    # stdout is a terminal — use colors
    readonly COLOR_RESET="\033[0m"
    readonly COLOR_GREEN="\033[0;32m"
    readonly COLOR_YELLOW="\033[0;33m"
    readonly COLOR_RED="\033[0;31m"
    readonly COLOR_CYAN="\033[0;36m"
    readonly COLOR_BOLD="\033[1m"
else
    # stdout is not a terminal (piped or redirected) — no colors
    readonly COLOR_RESET=""
    readonly COLOR_GREEN=""
    readonly COLOR_YELLOW=""
    readonly COLOR_RED=""
    readonly COLOR_CYAN=""
    readonly COLOR_BOLD=""
fi

# =============================================================================
# Logging Functions
# =============================================================================
# All output from install/ scripts must go through these functions.
# This ensures consistent formatting and makes it easy to add features
# (like log file writing) in one place without updating every script.

# log_info — prints an informational message (cyan prefix).
# Arguments:
#   $@ — the message to print
log_info() {
    echo -e "${COLOR_CYAN}[INFO]${COLOR_RESET}  $*"
}

# log_ok — prints a success message (green prefix).
# Arguments:
#   $@ — the message to print
log_ok() {
    echo -e "${COLOR_GREEN}[ OK ]${COLOR_RESET}  $*"
}

# log_warn — prints a warning message (yellow prefix). Does not exit.
# Arguments:
#   $@ — the message to print
log_warn() {
    echo -e "${COLOR_YELLOW}[WARN]${COLOR_RESET}  $*"
}

# log_error — prints an error message (red prefix) to stderr. Does not exit.
# The calling script is responsible for deciding whether to exit after an error.
# Arguments:
#   $@ — the message to print
log_error() {
    echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} $*" >&2
}

# log_section — prints a prominent section header to visually separate stages.
# Arguments:
#   $@ — the section title to print
log_section() {
    echo ""
    echo -e "${COLOR_BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo -e "${COLOR_BOLD}  $*${COLOR_RESET}"
    echo -e "${COLOR_BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo ""
}

# =============================================================================
# Utility Functions
# =============================================================================

# backup_file — creates a .bak copy of a file before it is modified.
# If the backup already exists, it is not overwritten (we keep the original).
# Arguments:
#   $1 — absolute path to the file to back up
backup_file() {
    local target_file="${1:?backup_file: file path required}"
    local backup_path="${target_file}${BACKUP_SUFFIX}"

    if [[ -f "${target_file}" && ! -f "${backup_path}" ]]; then
        cp "${target_file}" "${backup_path}"
        log_info "Backed up ${target_file} to ${backup_path}"
    fi
}

# command_exists — returns 0 if the given command is available in PATH.
# Arguments:
#   $1 — command name to check
# Returns:
#   0 if the command exists, 1 otherwise
command_exists() {
    command -v "${1}" &>/dev/null
}

# package_installed — returns 0 if the given pacman package is installed.
# Arguments:
#   $1 — package name to check
# Returns:
#   0 if installed, 1 otherwise
package_installed() {
    pacman -Q "${1}" &>/dev/null
}

# service_active — returns 0 if the given systemd service is currently active.
# Arguments:
#   $1 — service name (with or without .service suffix)
# Returns:
#   0 if active, 1 otherwise
service_active() {
    systemctl is-active --quiet "${1}"
}

# service_enabled — returns 0 if the given systemd service is enabled.
# Arguments:
#   $1 — service name
# Returns:
#   0 if enabled, 1 otherwise
service_enabled() {
    systemctl is-enabled --quiet "${1}"
}

# require_root — exits with an error if the current user is not root.
# Some operations (pacman, systemctl enable) require root privileges.
# Arguments: none
require_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        log_error "This script must be run as root (or via sudo)."
        log_error "Usage: sudo bash ${0}"
        exit 1
    fi
}

# require_not_root — exits with an error if the current user IS root.
# Some operations (AUR building, user-level config) must not run as root.
# Arguments: none
require_not_root() {
    if [[ "${EUID}" -eq 0 ]]; then
        log_error "This script must NOT be run as root."
        log_error "Run as your regular user account."
        exit 1
    fi
}
