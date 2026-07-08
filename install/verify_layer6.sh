#!/usr/bin/env bash
# =============================================================================
# Script Name: verify_layer6.sh
# Description: Verification script for Layer 6 — Applications, MIME, XDG.
#
# Usage:       bash install/verify_layer6.sh
# Exit codes:  0 — all checks passed, 1 — one or more failed
#
# Author:      project_arch contributors
# Layer:       Layer 6 — Applications
# =============================================================================

set -euo pipefail

CURRENT_LAYER="Layer 6"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

main() {
    log_section "Layer 6 — Applications Verification"

    set +e

    # -- Packages --
    log_info "Verifying packages..."
    v_check_package "thunar"
    v_check_package "gvfs"
    v_check_package "firefox"
    v_check_package "mpv"
    v_check_package "imv"
    v_check_package "evince"
    v_check_package "file-roller"
    v_check_package "xdg-utils"
    v_check_package "xdg-user-dirs"

    # -- Commands --
    log_info "Verifying commands..."
    v_check_command "thunar"       "Thunar file manager"
    v_check_command "firefox"      "Firefox browser"
    v_check_command "mpv"          "mpv media player"
    v_check_command "xdg-open"     "xdg-open"
    v_check_command "xdg-mime"     "xdg-mime"

    # -- MIME Config --
    log_info "Verifying MIME configuration..."
    local mimeapps="${XDG_CONFIG_HOME}/mimeapps.list"
    if [[ -f "${mimeapps}" ]]; then
        v_pass "mimeapps.list present"

        # Check a few key associations.
        if grep -q "firefox.desktop" "${mimeapps}" 2>/dev/null; then
            v_pass "Firefox set as default browser"
        else
            v_warn "Firefox not set in mimeapps.list"
        fi

        if grep -q "thunar.desktop" "${mimeapps}" 2>/dev/null; then
            v_pass "Thunar set as default file manager"
        else
            v_warn "Thunar not set in mimeapps.list"
        fi
    else
        v_warn "mimeapps.list not found — MIME defaults not configured"
    fi

    # -- XDG User Directories --
    log_info "Verifying XDG user directories..."
    v_check_dir "${HOME}/Downloads"
    v_check_dir "${HOME}/Documents"
    v_check_dir "${HOME}/Pictures"
    v_check_dir "${HOME}/Videos"
    v_check_dir "${HOME}/Music"

    # -- Desktop Entries --
    log_info "Verifying desktop entries..."
    v_check_dir "${XDG_DATA_HOME}/applications"

    set -e

    v_report "Layer 6"
}

main "$@"
