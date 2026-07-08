#!/usr/bin/env bash
# =============================================================================
# Script Name: verify_layer2.sh
# Description: Verification script for Layer 2 — Hyprland.
#              Checks packages, configs, services, and environment.
#
# Usage:       bash install/verify_layer2.sh
# Exit codes:  0 — all checks passed, 1 — one or more failed
#
# Author:      project_arch contributors
# Layer:       Layer 2 — Hyprland
# =============================================================================

set -euo pipefail

CURRENT_LAYER="Layer 2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

main() {
    log_section "Layer 2 — Hyprland Verification"

    set +e

    # -- Packages --
    log_info "Verifying packages..."
    v_check_package "hyprland"
    v_check_package "hyprlock"
    v_check_package "hypridle"
    v_check_package "hyprpaper"
    v_check_package "xdg-desktop-portal-hyprland"
    v_check_package "xdg-desktop-portal-gtk"
    v_check_package "pipewire"
    v_check_package "pipewire-pulse"
    v_check_package "wireplumber"
    v_check_package "grim"
    v_check_package "slurp"
    v_check_package "wl-clipboard"
    v_check_package "cliphist"
    v_check_package "brightnessctl"
    v_check_package "playerctl"
    v_check_package "polkit-gnome"

    # -- Commands --
    log_info "Verifying commands..."
    v_check_command "Hyprland"   "Hyprland compositor"
    v_check_command "hyprlock"   "hyprlock screen locker"
    v_check_command "hypridle"   "hypridle daemon"
    v_check_command "hyprpaper"  "hyprpaper wallpaper"
    v_check_command "grim"       "grim screenshot"
    v_check_command "slurp"      "slurp region selector"
    v_check_command "wpctl"      "WirePlumber control"
    v_check_command "pw-cli"     "PipeWire CLI"

    # -- Configuration Files --
    log_info "Verifying configuration files..."
    local hypr_dir="${XDG_CONFIG_HOME}/hypr"

    v_check_dir "${hypr_dir}"
    v_check_file "${hypr_dir}/hyprlock.conf"
    v_check_file "${hypr_dir}/hypridle.conf"
    v_check_file "${hypr_dir}/autostart.conf"

    # hyprland.conf is optional — warn if missing.
    if [[ -f "${hypr_dir}/hyprland.conf" ]]; then
        v_pass "hyprland.conf present"
    else
        v_warn "hyprland.conf not found — Hyprland will use defaults"
    fi

    # -- PipeWire User Services --
    log_info "Verifying PipeWire services..."
    v_check_service "pipewire.socket"       "user"
    v_check_service "pipewire-pulse.socket"  "user"
    v_check_service "wireplumber"            "user"

    # -- Wallpaper Directory --
    log_info "Verifying wallpaper directories..."
    v_check_dir "${HOME}/Pictures/Wallpapers"

    set -e

    v_report "Layer 2"
}

main "$@"
