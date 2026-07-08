#!/usr/bin/env bash
# =============================================================================
# Script Name: common.sh
# Description: Shared helper functions for Layer 2–7 installers. This file is
#              sourced by each layerN.sh and verify_layerN.sh script. It builds
#              on top of variables.sh, adding higher-level operations for config
#              deployment, backup management, and package installation.
#
# Usage:       source install/common.sh
#              (Never executed directly)
#
# Author:      project_arch contributors
# Layer:       Shared — Layers 2–7
# =============================================================================
#
# NOTE: This file intentionally does not call `set -euo pipefail`.
#       Strict mode is the responsibility of the calling script.

# Guard against double-sourcing.
[[ -n "${_COMMON_SH_LOADED:-}" ]] && return 0
_COMMON_SH_LOADED=1

# Resolve paths relative to this file.
_COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source variables.sh for constants, colors, and base utility functions.
# variables.sh provides: REPO_ROOT, XDG_CONFIG_HOME, XDG_DATA_HOME,
# BACKUP_SUFFIX, PACMAN_FLAGS, all COLOR_* vars, log_*, command_exists,
# package_installed, service_active, service_enabled, backup_file,
# require_root, require_not_root.
source "${_COMMON_DIR}/variables.sh"

# =============================================================================
# Layer Metadata
# =============================================================================

# CURRENT_LAYER is set by each layerN.sh script before sourcing common.sh.
# Default to "Unknown" if not set.
CURRENT_LAYER="${CURRENT_LAYER:-Unknown}"

# =============================================================================
# Logging Wrappers
# =============================================================================

# layer_banner — prints a prominent banner for the current layer installer.
# Arguments:
#   $1 — layer name (e.g., "Layer 2 — Hyprland")
#   $2 — short description
layer_banner() {
    local layer_name="${1:?layer_banner: layer name required}"
    local description="${2:-}"

    echo ""
    echo -e "${COLOR_BOLD}${COLOR_CYAN}"
    echo "  ┌─────────────────────────────────────────────────────┐"
    echo "  │                                                     │"
    printf "  │  %-51s │\n" "project_arch · ${layer_name}"
    printf "  │  %-51s │\n" "${description}"
    echo "  │                                                     │"
    echo "  └─────────────────────────────────────────────────────┘"
    echo -e "${COLOR_RESET}"
    echo -e "  Repository : ${REPO_ROOT}"
    echo -e "  User       : $(whoami)"
    echo -e "  Date       : $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
}

# =============================================================================
# Dependency Validation
# =============================================================================

# require_layer — checks that a previous layer's verify script passes.
# Arguments:
#   $1 — layer number to check (e.g., 1)
require_layer() {
    local layer_num="${1:?require_layer: layer number required}"
    local verify_script

    if [[ "${layer_num}" -eq 1 ]]; then
        verify_script="${_COMMON_DIR}/verify.sh"
    else
        verify_script="${_COMMON_DIR}/verify_layer${layer_num}.sh"
    fi

    if [[ ! -f "${verify_script}" ]]; then
        log_warn "Cannot verify Layer ${layer_num} — verify script not found: ${verify_script}"
        log_warn "Proceeding without dependency check."
        return 0
    fi

    log_info "Checking Layer ${layer_num} prerequisites..."
    if bash "${verify_script}" > /dev/null 2>&1; then
        log_ok "Layer ${layer_num} verification passed."
    else
        log_error "Layer ${layer_num} verification failed."
        log_error "Install Layer ${layer_num} first: bash install/layer${layer_num}.sh"
        exit 1
    fi
}

# =============================================================================
# Package Installation
# =============================================================================

# install_packages — installs a list of pacman packages idempotently.
# Arguments:
#   $1 — group name for logging
#   $@ — package names
install_packages() {
    local group_name="${1:?install_packages: group name required}"
    shift
    local packages=("$@")

    if [[ ${#packages[@]} -eq 0 ]]; then
        log_warn "No packages specified for group: ${group_name}"
        return 0
    fi

    log_info "Installing ${group_name}..."

    # Filter to only packages not yet installed to provide better logging.
    local to_install=()
    for pkg in "${packages[@]}"; do
        if ! package_installed "${pkg}"; then
            to_install+=("${pkg}")
        fi
    done

    if [[ ${#to_install[@]} -eq 0 ]]; then
        log_ok "${group_name}: all packages already installed."
        return 0
    fi

    log_info "Packages to install: ${to_install[*]}"

    if ! sudo pacman -S ${PACMAN_FLAGS} "${to_install[@]}"; then
        log_error "Failed to install packages in group: ${group_name}"
        return 1
    fi

    log_ok "${group_name}: ${#to_install[@]} package(s) installed."
}

# install_aur_packages — installs AUR packages via paru.
# Arguments:
#   $1 — group name for logging
#   $@ — AUR package names
install_aur_packages() {
    local group_name="${1:?install_aur_packages: group name required}"
    shift
    local packages=("$@")

    if [[ ${#packages[@]} -eq 0 ]]; then
        log_warn "No AUR packages specified for group: ${group_name}"
        return 0
    fi

    if ! command_exists paru; then
        log_error "paru is not installed. Run Layer 1 first: bash install/install.sh"
        return 1
    fi

    log_info "Installing AUR ${group_name}..."

    local to_install=()
    for pkg in "${packages[@]}"; do
        if ! package_installed "${pkg}"; then
            to_install+=("${pkg}")
        fi
    done

    if [[ ${#to_install[@]} -eq 0 ]]; then
        log_ok "AUR ${group_name}: all packages already installed."
        return 0
    fi

    log_info "AUR packages to install: ${to_install[*]}"

    if ! paru -S --noconfirm --needed "${to_install[@]}"; then
        log_error "Failed to install AUR packages in group: ${group_name}"
        return 1
    fi

    log_ok "AUR ${group_name}: ${#to_install[@]} package(s) installed."
}

# =============================================================================
# Configuration Deployment
# =============================================================================

# deploy_config — copies a config file or directory from the repo to the
# target location. Backs up the existing file if it differs from the repo
# version.
#
# Arguments:
#   $1 — source path (relative to REPO_ROOT)
#   $2 — destination path (absolute)
deploy_config() {
    local src_rel="${1:?deploy_config: source path required}"
    local dest="${2:?deploy_config: destination path required}"
    local src="${REPO_ROOT}/${src_rel}"

    if [[ ! -e "${src}" ]]; then
        log_error "Source not found: ${src}"
        return 1
    fi

    # Create parent directory if needed.
    local dest_dir
    dest_dir="$(dirname "${dest}")"
    [[ -d "${dest_dir}" ]] || mkdir -p "${dest_dir}"

    if [[ -d "${src}" ]]; then
        # Directory deployment — use rsync for idempotent copying.
        if command_exists rsync; then
            rsync -a --backup --suffix="${BACKUP_SUFFIX}" "${src}/" "${dest}/"
        else
            cp -r "${src}/." "${dest}/"
        fi
        log_ok "Deployed directory: ${src_rel} → ${dest}"
        return 0
    fi

    # File deployment.
    if [[ -f "${dest}" ]]; then
        # Check if files are identical — skip if so.
        if cmp -s "${src}" "${dest}"; then
            log_info "Already current: ${dest}"
            return 0
        fi

        # Files differ — backup before overwriting.
        backup_file "${dest}"
        log_warn "Overwriting: ${dest} (backup created)"
    fi

    cp "${src}" "${dest}"
    log_ok "Deployed: ${src_rel} → ${dest}"
}

# deploy_symlink — creates a symlink from a repo file to a target location.
# Arguments:
#   $1 — source path (relative to REPO_ROOT)
#   $2 — destination path (absolute)
deploy_symlink() {
    local src_rel="${1:?deploy_symlink: source path required}"
    local dest="${2:?deploy_symlink: destination path required}"
    local src="${REPO_ROOT}/${src_rel}"

    if [[ ! -e "${src}" ]]; then
        log_error "Source not found: ${src}"
        return 1
    fi

    local dest_dir
    dest_dir="$(dirname "${dest}")"
    [[ -d "${dest_dir}" ]] || mkdir -p "${dest_dir}"

    # If destination exists and is already the correct symlink, skip.
    if [[ -L "${dest}" ]] && [[ "$(readlink -f "${dest}")" == "$(readlink -f "${src}")" ]]; then
        log_info "Symlink already correct: ${dest}"
        return 0
    fi

    # If destination exists as a regular file, back it up.
    if [[ -e "${dest}" ]] && [[ ! -L "${dest}" ]]; then
        backup_file "${dest}"
        log_warn "Replacing file with symlink: ${dest}"
    fi

    ln -sf "${src}" "${dest}"
    log_ok "Symlinked: ${dest} → ${src}"
}

# =============================================================================
# Service Management
# =============================================================================

# enable_user_service — enables a systemd user service.
# Arguments:
#   $1 — service/socket name
#   $2 — description
enable_user_service() {
    local service_name="${1:?enable_user_service: service name required}"
    local description="${2:-${service_name}}"

    log_info "Enabling user service: ${description} (${service_name})"

    if ! systemctl --user enable "${service_name}" 2>/dev/null; then
        log_warn "Could not enable user service ${service_name}."
        return 0
    fi

    if ! systemctl --user start "${service_name}" 2>/dev/null; then
        log_warn "Service ${service_name} enabled but could not start now."
        return 0
    fi

    log_ok "${description} enabled and started."
}

# enable_system_service — enables a systemd system service.
# Arguments:
#   $1 — service name
#   $2 — description
enable_system_service() {
    local service_name="${1:?enable_system_service: service name required}"
    local description="${2:-${service_name}}"

    log_info "Enabling system service: ${description} (${service_name})"

    if ! sudo systemctl enable "${service_name}" 2>/dev/null; then
        log_warn "Could not enable ${service_name}."
        return 0
    fi

    if ! sudo systemctl start "${service_name}" 2>/dev/null; then
        log_warn "Service ${service_name} enabled but could not start now."
        return 0
    fi

    log_ok "${description} enabled and started."
}

# =============================================================================
# Permissions
# =============================================================================

# make_executable — sets +x on a file or all .sh files in a directory.
# Arguments:
#   $1 — file or directory path
make_executable() {
    local target="${1:?make_executable: path required}"

    if [[ -f "${target}" ]]; then
        chmod +x "${target}"
        log_ok "Made executable: ${target}"
    elif [[ -d "${target}" ]]; then
        find "${target}" -type f -name "*.sh" -exec chmod +x {} \;
        log_ok "Made all .sh files executable in: ${target}"
    else
        log_warn "Not found: ${target}"
    fi
}

# =============================================================================
# Verification Helpers (for verify_layerN.sh scripts)
# =============================================================================

# These counters are used by the verify scripts.
VERIFY_PASS=0
VERIFY_FAIL=0
VERIFY_WARN=0

# v_pass — record a passing check.
v_pass() {
    VERIFY_PASS=$(( VERIFY_PASS + 1 ))
    echo -e "  ${COLOR_GREEN}[PASS]${COLOR_RESET}    $*"
}

# v_fail — record a failing check.
v_fail() {
    VERIFY_FAIL=$(( VERIFY_FAIL + 1 ))
    echo -e "  ${COLOR_RED}[FAIL]${COLOR_RESET}    $*"
}

# v_warn — record a warning (non-fatal).
v_warn() {
    VERIFY_WARN=$(( VERIFY_WARN + 1 ))
    echo -e "  ${COLOR_YELLOW}[WARNING]${COLOR_RESET} $*"
}

# v_check_command — verify a command exists.
v_check_command() {
    local cmd="${1:?v_check_command: command required}"
    local desc="${2:-${cmd}}"

    if command_exists "${cmd}"; then
        v_pass "${desc} is available"
    else
        v_fail "${desc} is NOT installed"
    fi
}

# v_check_package — verify a pacman/AUR package is installed.
v_check_package() {
    local pkg="${1:?v_check_package: package required}"

    if package_installed "${pkg}"; then
        v_pass "Package '${pkg}' installed"
    else
        v_fail "Package '${pkg}' NOT installed"
    fi
}

# v_check_file — verify a file exists.
v_check_file() {
    local file="${1:?v_check_file: file required}"

    if [[ -f "${file}" ]]; then
        v_pass "File exists: ${file}"
    else
        v_fail "File MISSING: ${file}"
    fi
}

# v_check_dir — verify a directory exists.
v_check_dir() {
    local dir="${1:?v_check_dir: directory required}"

    if [[ -d "${dir}" ]]; then
        v_pass "Directory exists: ${dir}"
    else
        v_fail "Directory MISSING: ${dir}"
    fi
}

# v_check_symlink — verify a symlink exists and points to the correct target.
v_check_symlink() {
    local link="${1:?v_check_symlink: link path required}"
    local expected_target="${2:-}"

    if [[ ! -L "${link}" ]]; then
        v_fail "Not a symlink: ${link}"
        return
    fi

    if [[ -n "${expected_target}" ]]; then
        local actual
        actual="$(readlink -f "${link}")"
        if [[ "${actual}" == "$(readlink -f "${expected_target}")" ]]; then
            v_pass "Symlink correct: ${link}"
        else
            v_fail "Symlink wrong target: ${link} → ${actual} (expected ${expected_target})"
        fi
    else
        v_pass "Symlink exists: ${link}"
    fi
}

# v_check_service — verify a systemd service is enabled.
v_check_service() {
    local svc="${1:?v_check_service: service required}"
    local user_flag="${2:-system}"

    if [[ "${user_flag}" == "user" ]]; then
        if systemctl --user is-enabled --quiet "${svc}" 2>/dev/null; then
            v_pass "User service '${svc}' enabled"
        else
            v_fail "User service '${svc}' NOT enabled"
        fi
    else
        if service_enabled "${svc}"; then
            v_pass "Service '${svc}' enabled"
        else
            v_fail "Service '${svc}' NOT enabled"
        fi
    fi
}

# v_report — prints the verification summary and sets exit code.
# Arguments:
#   $1 — layer name for the report header
v_report() {
    local layer_name="${1:-${CURRENT_LAYER}}"
    local total=$(( VERIFY_PASS + VERIFY_FAIL ))

    echo ""
    echo -e "${COLOR_BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo -e "${COLOR_BOLD}  ${layer_name} — Verification Report${COLOR_RESET}"
    echo -e "${COLOR_BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo ""
    echo -e "  Total checks : ${total}"
    echo -e "  ${COLOR_GREEN}PASS${COLOR_RESET}         : ${VERIFY_PASS}"
    echo -e "  ${COLOR_RED}FAIL${COLOR_RESET}         : ${VERIFY_FAIL}"
    echo -e "  ${COLOR_YELLOW}WARNING${COLOR_RESET}      : ${VERIFY_WARN}"
    echo ""

    if [[ "${VERIFY_FAIL}" -eq 0 ]]; then
        echo -e "  ${COLOR_GREEN}${COLOR_BOLD}All checks passed.${COLOR_RESET}"
    else
        echo -e "  ${COLOR_RED}${COLOR_BOLD}${VERIFY_FAIL} check(s) failed.${COLOR_RESET}"
    fi

    echo ""
    echo -e "${COLOR_BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"

    # Return exit code based on failures.
    [[ "${VERIFY_FAIL}" -eq 0 ]]
}
