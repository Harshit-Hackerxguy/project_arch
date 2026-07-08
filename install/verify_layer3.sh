#!/usr/bin/env bash
# =============================================================================
# Script Name: verify_layer3.sh
# Description: Verification script for Layer 3 — Waybar, Rofi, Dunst.
#
# Usage:       bash install/verify_layer3.sh
# Exit codes:  0 — all checks passed, 1 — one or more failed
#
# Author:      project_arch contributors
# Layer:       Layer 3 — Desktop UI
# =============================================================================

set -euo pipefail

CURRENT_LAYER="Layer 3"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

main() {
    log_section "Layer 3 — Desktop UI Verification"

    set +e

    # -- Packages --
    log_info "Verifying packages..."
    v_check_package "waybar"
    v_check_package "rofi-wayland"
    v_check_package "dunst"
    v_check_package "libnotify"

    # -- Commands --
    log_info "Verifying commands..."
    v_check_command "waybar"        "Waybar status bar"
    v_check_command "rofi"          "Rofi launcher"
    v_check_command "dunst"         "Dunst notification daemon"
    v_check_command "dunstctl"      "Dunst control"
    v_check_command "notify-send"   "notify-send"

    # -- Waybar Config --
    log_info "Verifying Waybar configuration..."
    v_check_dir  "${XDG_CONFIG_HOME}/waybar"
    v_check_file "${XDG_CONFIG_HOME}/waybar/config.jsonc"
    v_check_file "${XDG_CONFIG_HOME}/waybar/style.css"

    # -- Rofi Config --
    log_info "Verifying Rofi configuration..."
    v_check_dir  "${XDG_CONFIG_HOME}/rofi"
    v_check_file "${XDG_CONFIG_HOME}/rofi/config.rasi"

    # -- Dunst Config --
    log_info "Verifying Dunst configuration..."
    v_check_dir  "${XDG_CONFIG_HOME}/dunst"
    v_check_file "${XDG_CONFIG_HOME}/dunst/dunstrc"

    set -e

    v_report "Layer 3"
}

main "$@"
