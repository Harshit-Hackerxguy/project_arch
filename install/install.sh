#!/usr/bin/env bash
# =============================================================================
# Script Name: install.sh
# Description: Main entry point for the project_arch Layer 1 installation.
#              This script orchestrates all Layer 1 sub-scripts in the correct
#              order. It is the only script the user needs to run directly.
#
#              Execution order:
#                1. Preflight checks (network, user, OS validation)
#                2. packages.sh  — install packages
#                3. services.sh  — enable systemd services
#                4. directories.sh — create directory structure
#                5. shell.sh     — configure shell environment
#                6. verify.sh    — validate the installation
#
# Usage:       bash install/install.sh
#
#              Do NOT run as root. The script will invoke sudo where needed.
#              You will be prompted for your sudo password.
#
# Environment: No special environment variables required to start.
#              All variables are defined in variables.sh.
#
# Author:      project_arch contributors
# Layer:       Layer 1 — Base System
# =============================================================================

set -euo pipefail

# Resolve the directory containing this script, regardless of where it
# is called from. All sub-scripts are located in the same directory.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source shared variables and utility functions.
source "${SCRIPT_DIR}/variables.sh"

# =============================================================================
# Preflight Checks
# =============================================================================
# These checks run before anything is installed or modified. If any preflight
# check fails, the installation aborts cleanly without making changes.

# preflight_check_not_root — ensure the user is not running as root.
# Running the installer as root bypasses user-level configuration steps and
# can cause files to be owned by root in places where they should be user-owned.
preflight_check_not_root() {
    if [[ "${EUID}" -eq 0 ]]; then
        log_error "Do not run install.sh as root."
        log_error "Run as your regular user: bash install/install.sh"
        log_error "The script will prompt for your sudo password when needed."
        exit 1
    fi
    log_ok "Running as user: $(whoami)"
}

# preflight_check_sudo — verify that the user can use sudo.
# This prompts for the password once at the start so subsequent sudo
# calls in sub-scripts do not interrupt the automated flow.
preflight_check_sudo() {
    log_info "Verifying sudo access..."
    if ! sudo -v; then
        log_error "Cannot obtain sudo privileges."
        log_error "Ensure your user is in the wheel group: gpasswd -a $(whoami) wheel"
        exit 1
    fi
    log_ok "sudo access confirmed."

    # Keep the sudo timestamp alive for the duration of the install.
    # This runs in the background, refreshing every 50 seconds so the
    # user is not repeatedly prompted for their password during a long install.
    (
        while true; do
            sudo -n true
            sleep 50
            kill -0 "$$" 2>/dev/null || exit  # Stop if the parent exits.
        done
    ) &
    # Store the PID of the background process so we can kill it on exit.
    readonly SUDO_KEEPALIVE_PID=$!
    # shellcheck disable=SC2064
    trap "kill ${SUDO_KEEPALIVE_PID} 2>/dev/null; exit" EXIT INT TERM
}

# preflight_check_os — verify that we are running on Arch Linux.
# This project is Arch-specific (uses pacman, systemd with Arch conventions).
# Running it on another distribution will likely fail or cause unexpected results.
preflight_check_os() {
    log_info "Verifying operating system..."

    if [[ ! -f /etc/arch-release ]]; then
        log_error "This installer is designed for Arch Linux only."
        log_error "/etc/arch-release not found — this does not appear to be Arch Linux."
        exit 1
    fi
    log_ok "Operating system: Arch Linux"
}

# preflight_check_network — verify that the internet is reachable.
# Package installation requires network access. Failing early with a clear
# message is better than failing mid-install after partial changes.
preflight_check_network() {
    log_info "Checking network connectivity..."

    # Test connectivity to the Arch Linux package servers.
    if ! curl --silent --max-time 10 --head https://archlinux.org > /dev/null; then
        log_error "Cannot reach archlinux.org."
        log_error "Check your network connection and try again."
        log_error "If using WiFi: nmcli device wifi list && nmcli device wifi connect SSID password PASSWORD"
        exit 1
    fi
    log_ok "Network connectivity confirmed."
}

# preflight_check_pacman — verify that pacman is healthy before we begin.
preflight_check_pacman() {
    log_info "Checking pacman..."

    if ! command_exists pacman; then
        log_error "pacman not found. This installer requires an Arch Linux system."
        exit 1
    fi

    # Check for a stale lock file that would block all pacman operations.
    if [[ -f /var/lib/pacman/db.lck ]]; then
        log_error "Pacman lock file exists: /var/lib/pacman/db.lck"
        log_error "Is another pacman process running?"
        log_error "If not, remove the stale lock: sudo rm /var/lib/pacman/db.lck"
        exit 1
    fi

    log_ok "pacman is healthy."
}

# preflight_check_git — verify that git is available to clone AUR packages.
# git may need to be installed first if this is a completely bare system.
preflight_check_git() {
    if ! command_exists git; then
        log_warn "git is not installed. Installing it now before proceeding..."
        sudo pacman -S --noconfirm --needed git || {
            log_error "Failed to install git. Cannot continue."
            exit 1
        }
        log_ok "git installed."
    else
        log_ok "git is available: $(git --version)"
    fi
}

# run_preflight_checks — runs all preflight checks in order.
run_preflight_checks() {
    log_section "Preflight Checks"

    preflight_check_not_root
    preflight_check_os
    preflight_check_network
    preflight_check_pacman
    preflight_check_sudo
    preflight_check_git

    log_ok "All preflight checks passed. Starting installation."
}

# =============================================================================
# Stage Execution
# =============================================================================

# run_stage — executes a sub-script as a named installation stage.
# Handles logging the stage start/end and detecting failures.
# Arguments:
#   $1 — human-readable stage name
#   $2 — path to the script to execute
run_stage() {
    local stage_name="${1:?run_stage: stage name required}"
    local script_path="${2:?run_stage: script path required}"

    if [[ ! -f "${script_path}" ]]; then
        log_error "Stage script not found: ${script_path}"
        exit 1
    fi

    log_section "Stage: ${stage_name}"

    # Execute the stage script. It will inherit the current shell options
    # (set -euo pipefail) and will exit with a non-zero status on failure.
    if ! bash "${script_path}"; then
        log_error "Stage '${stage_name}' failed."
        log_error "Installation aborted. Fix the error above and re-run install.sh."
        log_error "The installer is idempotent — completed stages will be skipped."
        exit 1
    fi

    log_ok "Stage '${stage_name}' completed successfully."
}

# =============================================================================
# Installation Banner
# =============================================================================

print_banner() {
    echo ""
    echo -e "${COLOR_BOLD}${COLOR_CYAN}"
    echo "  ┌─────────────────────────────────────────────────────┐"
    echo "  │                                                     │"
    echo "  │           project_arch  ·  Layer 1 Installer        │"
    echo "  │           Base System Setup                         │"
    echo "  │                                                     │"
    echo "  └─────────────────────────────────────────────────────┘"
    echo -e "${COLOR_RESET}"
    echo -e "  Repository : ${REPO_ROOT}"
    echo -e "  User       : $(whoami)"
    echo -e "  Home       : ${HOME}"
    echo -e "  Date       : $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    echo -e "  ${COLOR_YELLOW}Read all scripts before proceeding if you have not already.${COLOR_RESET}"
    echo -e "  ${COLOR_YELLOW}This installer will modify system packages and user files.${COLOR_RESET}"
    echo ""
}

# =============================================================================
# Main
# =============================================================================

main() {
    print_banner

    # Pause to let the user read the banner and abort if needed.
    # In non-interactive mode (pipe or CI), this is skipped.
    if [[ -t 0 ]]; then
        read -r -p "  Press Enter to begin, or Ctrl+C to abort... "
        echo ""
    fi

    run_preflight_checks

    # Execute each installation stage in order.
    # Each stage is a separate script with a single responsibility.
    run_stage "Package Installation"     "${SCRIPT_DIR}/packages.sh"
    run_stage "Service Configuration"    "${SCRIPT_DIR}/services.sh"
    run_stage "Directory Setup"          "${SCRIPT_DIR}/directories.sh"
    run_stage "Shell Environment"        "${SCRIPT_DIR}/shell.sh"
    run_stage "Verification"             "${SCRIPT_DIR}/verify.sh"

    # Installation complete.
    log_section "Layer 1 Installation Complete"

    echo -e "  ${COLOR_GREEN}${COLOR_BOLD}Layer 1 is complete.${COLOR_RESET}"
    echo ""
    echo -e "  ${COLOR_CYAN}Next steps:${COLOR_RESET}"
    echo -e "  1. Review any warnings printed above."
    echo -e "  2. Log out and log back in to activate the new shell environment."
    echo -e "  3. Run  ${COLOR_BOLD}bash install/verify.sh${COLOR_RESET}  in the new session to confirm."
    echo -e "  4. When ready, proceed to Layer 2 (Hyprland configuration)."
    echo ""
    echo -e "  See ${COLOR_BOLD}docs/installation.md${COLOR_RESET} for the full installation guide."
    echo ""
}

main "$@"
