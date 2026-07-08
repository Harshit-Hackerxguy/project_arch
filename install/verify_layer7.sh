#!/usr/bin/env bash
# =============================================================================
# Script Name: verify_layer7.sh
# Description: Verification script for Layer 7 — Scripts, maintenance,
#              permissions, and system optimizations.
#
# Usage:       bash install/verify_layer7.sh
# Exit codes:  0 — all checks passed, 1 — one or more failed
#
# Author:      project_arch contributors
# Layer:       Layer 7 — Utilities & Maintenance
# =============================================================================

set -euo pipefail

CURRENT_LAYER="Layer 7"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

main() {
    log_section "Layer 7 — Utilities & Maintenance Verification"

    set +e

    # -- Packages --
    log_info "Verifying packages..."
    v_check_package "cronie"
    v_check_package "pacman-contrib"
    v_check_package "imagemagick"
    v_check_package "tesseract"
    v_check_package "bc"

    # -- Commands --
    log_info "Verifying commands..."
    v_check_command "paccache"     "paccache cache cleaner"
    v_check_command "checkupdates" "checkupdates"
    v_check_command "convert"      "ImageMagick convert"
    v_check_command "tesseract"    "Tesseract OCR"
    v_check_command "bc"           "bc calculator"
    v_check_command "crontab"      "crontab"

    # -- Scripts Deployment --
    log_info "Verifying script deployment..."
    local scripts_dir="${XDG_CONFIG_HOME}/scripts"

    v_check_dir "${scripts_dir}"

    # Check for specific script subdirectories that should exist.
    local expected_dirs=("audio" "power" "screenshots" "utilities")
    for dir in "${expected_dirs[@]}"; do
        if [[ -d "${scripts_dir}/${dir}" ]]; then
            v_pass "Script directory: ${dir}/"
        else
            v_warn "Script directory missing: ${dir}/ — may not be in repo yet"
        fi
    done

    # -- Script Permissions --
    log_info "Verifying script permissions..."
    local non_exec=0
    if [[ -d "${scripts_dir}" ]]; then
        while IFS= read -r -d '' script; do
            if [[ ! -x "${script}" ]]; then
                non_exec=$(( non_exec + 1 ))
            fi
        done < <(find "${scripts_dir}" -type f -name "*.sh" -print0 2>/dev/null)

        if [[ "${non_exec}" -eq 0 ]]; then
            v_pass "All scripts are executable"
        else
            v_fail "${non_exec} script(s) are not executable"
        fi
    fi

    # -- System Services --
    log_info "Verifying system services..."
    v_check_service "cronie.service"

    if systemctl list-unit-files "paccache.timer" &>/dev/null; then
        v_check_service "paccache.timer"
    else
        v_warn "paccache.timer unit not found — may need pacman-contrib >= 1.10"
    fi

    # -- Sysctl Optimizations --
    log_info "Verifying sysctl optimizations..."
    local sysctl_conf="/etc/sysctl.d/99-project-arch.conf"
    if [[ -f "${sysctl_conf}" ]]; then
        v_pass "Sysctl config present: ${sysctl_conf}"
    else
        v_warn "Sysctl config not found — optimizations not applied"
    fi

    # Check a key sysctl value.
    local swappiness
    swappiness="$(cat /proc/sys/vm/swappiness 2>/dev/null || echo "")"
    if [[ "${swappiness}" -le 10 ]] 2>/dev/null; then
        v_pass "vm.swappiness = ${swappiness} (≤ 10)"
    elif [[ -n "${swappiness}" ]]; then
        v_warn "vm.swappiness = ${swappiness} (recommended: ≤ 10)"
    fi

    set -e

    v_report "Layer 7"
}

main "$@"
