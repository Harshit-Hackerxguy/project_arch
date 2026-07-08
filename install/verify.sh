#!/usr/bin/env bash
# =============================================================================
# Script Name: verify.sh
# Description: Post-installation verification for Layer 1. Checks that all
#              expected packages, services, directories, and environment
#              variables are in place. Exits with a non-zero status if any
#              check fails, making it usable in CI or automated workflows.
#
#              Run this script after install.sh to confirm Layer 1 is complete.
#
# Usage:       bash install/verify.sh
#              (or called from install.sh — preferred)
#
# Environment: Reads shared variables from variables.sh (auto-sourced).
#
# Exit codes:
#   0 — all checks passed
#   1 — one or more checks failed
#
# Author:      project_arch contributors
# Layer:       Layer 1 — Base System
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/variables.sh"

# =============================================================================
# Verification State
# =============================================================================

# Counters track pass/fail across all checks.
PASS_COUNT=0
FAIL_COUNT=0

# =============================================================================
# Verification Helper Functions
# =============================================================================

# check_pass — record a passing check and print a success message.
# Arguments:
#   $@ — the description of what passed
check_pass() {
    PASS_COUNT=$(( PASS_COUNT + 1 ))
    log_ok "$*"
}

# check_fail — record a failing check and print a failure message.
# Does NOT exit — we collect all failures and report them at the end.
# Arguments:
#   $@ — the description of what failed
check_fail() {
    FAIL_COUNT=$(( FAIL_COUNT + 1 ))
    log_error "FAIL: $*"
}

# verify_command — checks that a command is available in PATH.
# Arguments:
#   $1 — command name to check
#   $2 — optional: human-readable description (defaults to command name)
verify_command() {
    local cmd="${1:?verify_command: command required}"
    local desc="${2:-${cmd}}"

    if command_exists "${cmd}"; then
        check_pass "${desc} is available ($(command -v "${cmd}"))"
    else
        check_fail "${desc} is NOT available — is it installed? (expected command: ${cmd})"
    fi
}

# verify_package — checks that a pacman package is installed.
# Arguments:
#   $1 — package name
verify_package() {
    local pkg="${1:?verify_package: package name required}"

    if package_installed "${pkg}"; then
        local version
        version=$(pacman -Q "${pkg}" | awk '{print $2}')
        check_pass "Package '${pkg}' is installed (version: ${version})"
    else
        check_fail "Package '${pkg}' is NOT installed"
    fi
}

# verify_service_enabled — checks that a systemd service is enabled.
# Arguments:
#   $1 — service name
verify_service_enabled() {
    local svc="${1:?verify_service_enabled: service name required}"

    if service_enabled "${svc}"; then
        check_pass "Service '${svc}' is enabled"
    else
        check_fail "Service '${svc}' is NOT enabled"
    fi
}

# verify_service_active — checks that a systemd service is currently running.
# Arguments:
#   $1 — service name
verify_service_active() {
    local svc="${1:?verify_service_active: service name required}"

    if service_active "${svc}"; then
        check_pass "Service '${svc}' is active (running)"
    else
        check_fail "Service '${svc}' is NOT active"
    fi
}

# verify_directory — checks that a directory exists.
# Arguments:
#   $1 — directory path
verify_directory() {
    local dir="${1:?verify_directory: directory path required}"

    if [[ -d "${dir}" ]]; then
        check_pass "Directory exists: ${dir}"
    else
        check_fail "Directory MISSING: ${dir}"
    fi
}

# verify_file — checks that a file exists.
# Arguments:
#   $1 — file path
verify_file() {
    local file="${1:?verify_file: file path required}"

    if [[ -f "${file}" ]]; then
        check_pass "File exists: ${file}"
    else
        check_fail "File MISSING: ${file}"
    fi
}

# verify_env_var — checks that an environment variable is set and non-empty.
# Arguments:
#   $1 — variable name (without $)
#   $2 — optional: expected value (checks exact match if provided)
verify_env_var() {
    local var_name="${1:?verify_env_var: variable name required}"
    local expected_value="${2:-}"

    # Use indirect expansion to get the variable's value.
    local actual_value="${!var_name:-}"

    if [[ -z "${actual_value}" ]]; then
        check_fail "Environment variable \$${var_name} is not set or empty"
        return
    fi

    if [[ -n "${expected_value}" && "${actual_value}" != "${expected_value}" ]]; then
        check_fail "\$${var_name} = '${actual_value}' (expected: '${expected_value}')"
        return
    fi

    check_pass "\$${var_name} = '${actual_value}'"
}

# =============================================================================
# Verification Suites
# =============================================================================

# verify_essential_commands — checks for commands that must be in PATH.
verify_essential_commands() {
    log_info "Verifying essential commands..."

    # Core tools
    verify_command "git"        "Git version control"
    verify_command "curl"       "curl HTTP client"
    verify_command "wget"       "wget download tool"
    verify_command "rsync"      "rsync file sync"
    verify_command "ssh"        "OpenSSH client"
    verify_command "gpg"        "GNU Privacy Guard"

    # Build tools
    verify_command "gcc"        "GCC compiler"
    verify_command "make"       "GNU Make"
    verify_command "cmake"      "CMake build system"
    verify_command "meson"      "Meson build system"

    # Terminal tools
    verify_command "nvim"       "Neovim editor"
    verify_command "rg"         "ripgrep search"
    verify_command "fd"         "fd find tool"
    verify_command "fzf"        "fzf fuzzy finder"
    verify_command "bat"        "bat (cat replacement)"
    verify_command "eza"        "eza (ls replacement)"
    verify_command "zoxide"     "zoxide (cd replacement)"
    verify_command "htop"       "htop process viewer"
    verify_command "btop"       "btop resource monitor"

    # System tools
    verify_command "reflector"  "reflector mirror manager"
    verify_command "paru"       "paru AUR helper"
    verify_command "python"     "Python 3 interpreter"
    verify_command "pip"        "Python pip"
    verify_command "jq"         "jq JSON processor"
}

# verify_packages — spot-checks key packages via pacman.
verify_packages() {
    log_info "Verifying installed packages..."

    verify_package "git"
    verify_package "base-devel"
    verify_package "neovim"
    verify_package "networkmanager"
    verify_package "openssh"
    verify_package "gnupg"
    verify_package "reflector"
    verify_package "ttf-jetbrains-mono-nerd"
    verify_package "noto-fonts"
    verify_package "noto-fonts-emoji"
}

# verify_services — checks that all Layer 1 services are enabled.
# Note: active (running) checks are separate from enabled (start-at-boot) checks.
verify_services() {
    log_info "Verifying systemd services..."

    # Enabled checks (all should be enabled)
    verify_service_enabled "NetworkManager"
    verify_service_enabled "bluetooth"
    verify_service_enabled "fstrim.timer"
    verify_service_enabled "systemd-timesyncd"

    # Active checks (may not be active if reboot is pending)
    verify_service_active "NetworkManager"
    verify_service_active "systemd-timesyncd"
}

# verify_directories — checks that all Layer 1 directories exist.
verify_directories() {
    log_info "Verifying directories..."

    # XDG Base Directories
    verify_directory "${HOME}/.config"
    verify_directory "${HOME}/.local/share"
    verify_directory "${HOME}/.local/state"
    verify_directory "${HOME}/.cache"
    verify_directory "${HOME}/.local/bin"

    # XDG User Directories
    verify_directory "${HOME}/Downloads"
    verify_directory "${HOME}/Documents"
    verify_directory "${HOME}/Pictures"
    verify_directory "${HOME}/Videos"
    verify_directory "${HOME}/Music"

    # Application Config Dirs
    verify_directory "${HOME}/.config/hypr"
    verify_directory "${HOME}/.config/waybar"
    verify_directory "${HOME}/.config/rofi"
    verify_directory "${HOME}/.config/dunst"
    verify_directory "${HOME}/.config/kitty"
    verify_directory "${HOME}/.config/nvim"

    # Development Workspace
    verify_directory "${HOME}/dev"
    verify_directory "${HOME}/dev/personal"

    # Media
    verify_directory "${HOME}/Pictures/Wallpapers"
    verify_directory "${HOME}/Pictures/Screenshots"
}

# verify_shell_config — checks that shell configuration files exist and
# contain the project_arch configuration block.
verify_shell_config() {
    log_info "Verifying shell configuration..."

    verify_file "${HOME}/.bash_profile"
    verify_file "${HOME}/.bashrc"
    verify_file "${HOME}/.config/environment.d/project_arch.conf"

    # Check that our configuration marker is present in the shell files.
    if grep -q "project_arch configuration" "${HOME}/.bash_profile" 2>/dev/null; then
        check_pass "project_arch block present in .bash_profile"
    else
        check_fail "project_arch configuration block NOT found in .bash_profile"
    fi

    if grep -q "project_arch configuration" "${HOME}/.bashrc" 2>/dev/null; then
        check_pass "project_arch block present in .bashrc"
    else
        check_fail "project_arch configuration block NOT found in .bashrc"
    fi
}

# verify_environment_variables — checks that key variables are set.
# NOTE: These checks will PASS only if you have sourced the new profile
# in the current session. If not, source it first:
#   source ~/.bash_profile
verify_environment_variables() {
    log_info "Verifying environment variables..."
    log_warn "Note: source ~/.bash_profile first if you see failures here."

    verify_env_var "XDG_CONFIG_HOME"
    verify_env_var "XDG_DATA_HOME"
    verify_env_var "XDG_CACHE_HOME"
    verify_env_var "EDITOR"
    verify_env_var "VISUAL"
}

# =============================================================================
# Report
# =============================================================================

# print_report — prints the final verification summary.
print_report() {
    local total=$(( PASS_COUNT + FAIL_COUNT ))

    echo ""
    echo -e "${COLOR_BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo -e "${COLOR_BOLD}  Layer 1 Verification Report${COLOR_RESET}"
    echo -e "${COLOR_BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
    echo ""
    echo -e "  Total checks : ${total}"
    echo -e "  ${COLOR_GREEN}Passed${COLOR_RESET}       : ${PASS_COUNT}"
    echo -e "  ${COLOR_RED}Failed${COLOR_RESET}       : ${FAIL_COUNT}"
    echo ""

    if [[ "${FAIL_COUNT}" -eq 0 ]]; then
        echo -e "  ${COLOR_GREEN}${COLOR_BOLD}All checks passed. Layer 1 is complete.${COLOR_RESET}"
        echo -e "  ${COLOR_CYAN}Next step: Log out and back in, then proceed to Layer 2.${COLOR_RESET}"
    else
        echo -e "  ${COLOR_RED}${COLOR_BOLD}${FAIL_COUNT} check(s) failed. Review the errors above.${COLOR_RESET}"
        echo -e "  See docs/troubleshooting.md for remediation steps."
    fi

    echo ""
    echo -e "${COLOR_BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${COLOR_RESET}"
}

# =============================================================================
# Main
# =============================================================================

main() {
    log_section "Layer 1 — Post-Installation Verification"

    # Run all verification suites. Each suite reports its own results.
    # We do not exit on first failure — we collect all failures.
    set +e    # Temporarily disable errexit so individual check failures
              # do not abort the entire verification run.

    verify_essential_commands
    verify_packages
    verify_services
    verify_directories
    verify_shell_config
    verify_environment_variables

    set -e    # Re-enable errexit

    # Print the final report
    print_report

    # Exit with non-zero status if any checks failed.
    # This allows verify.sh to be used in automated pipelines.
    if [[ "${FAIL_COUNT}" -gt 0 ]]; then
        exit 1
    fi

    exit 0
}

main "$@"
