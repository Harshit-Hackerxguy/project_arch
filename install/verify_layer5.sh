#!/usr/bin/env bash
# =============================================================================
# Script Name: verify_layer5.sh
# Description: Verification script for Layer 5 — GTK, icons, cursors, fonts.
#
# Usage:       bash install/verify_layer5.sh
# Exit codes:  0 — all checks passed, 1 — one or more failed
#
# Author:      project_arch contributors
# Layer:       Layer 5 — Theming
# =============================================================================

set -euo pipefail

CURRENT_LAYER="Layer 5"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

main() {
    log_section "Layer 5 — Theming Verification"

    set +e

    # -- Packages --
    log_info "Verifying packages..."
    v_check_package "gtk3"
    v_check_package "gtk4"
    v_check_package "gnome-themes-extra"
    v_check_package "papirus-icon-theme"
    v_check_package "nwg-look"
    v_check_package "qt5ct"
    v_check_package "ttf-jetbrains-mono-nerd"
    v_check_package "noto-fonts"
    v_check_package "noto-fonts-emoji"
    v_check_package "ttf-font-awesome"
    v_check_package "inter-font"

    # -- AUR Packages --
    log_info "Verifying AUR packages..."
    v_check_package "bibata-cursor-theme"

    # -- Commands --
    log_info "Verifying commands..."
    v_check_command "nwg-look"    "nwg-look GTK editor"
    v_check_command "qt5ct"       "Qt5 configuration tool"
    v_check_command "fc-list"     "Fontconfig list"

    # -- GTK Config --
    log_info "Verifying GTK configuration..."
    v_check_file "${XDG_CONFIG_HOME}/gtk-3.0/settings.ini"
    v_check_file "${XDG_CONFIG_HOME}/gtk-4.0/settings.ini"

    # -- Cursor Config --
    log_info "Verifying cursor configuration..."
    v_check_file "${XDG_CONFIG_HOME}/environment.d/cursor.conf"

    if [[ -f "${HOME}/.local/share/icons/default/index.theme" ]]; then
        v_pass "Default cursor index.theme present"
    else
        v_warn "Default cursor index.theme not found"
    fi

    # -- Font Check --
    log_info "Verifying fonts..."

    if package_installed "ttf-jetbrains-mono-nerd"; then
        v_pass "JetBrains Nerd Font package installed"
    else
        v_fail "JetBrains Nerd Font package NOT installed"
    fi

    if package_installed "noto-fonts"; then
        v_pass "Noto Sans package installed"
    else
        v_fail "Noto Sans package NOT installed"
    fi

    set -e

    v_report "Layer 5"
}

main "$@"
