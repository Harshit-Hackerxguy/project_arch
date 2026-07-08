#!/usr/bin/env bash
# =============================================================================
# Script Name: layer3.sh
# Description: Layer 3 installer — Waybar, Rofi, and Dunst.
#
#              Installs and configures:
#                - Waybar (status bar)
#                - Rofi (application launcher)
#                - Dunst (notification daemon)
#
# Usage:       bash install/layer3.sh
# Requires:    Layer 2 must be installed first.
#
# Author:      project_arch contributors
# Layer:       Layer 3 — Desktop UI
# =============================================================================

set -euo pipefail

CURRENT_LAYER="Layer 3"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# =============================================================================
# Package Definitions
# =============================================================================

readonly LAYER3_PACKAGES=(
    "waybar"                      # Highly customizable status bar
    "rofi-wayland"                # Application launcher (Wayland fork)
    "dunst"                       # Lightweight notification daemon
    "libnotify"                   # notify-send command for sending notifications
)

# =============================================================================
# Configuration Deployment
# =============================================================================

deploy_waybar_config() {
    log_info "Deploying Waybar configuration..."

    local dest="${XDG_CONFIG_HOME}/waybar"
    mkdir -p "${dest}"

    # Deploy main config and stylesheet.
    deploy_config "waybar/config.jsonc" "${dest}/config.jsonc"
    deploy_config "waybar/style.css"    "${dest}/style.css"

    # Deploy modules directory if it exists.
    if [[ -d "${REPO_ROOT}/waybar/modules" ]]; then
        deploy_config "waybar/modules" "${dest}/modules"
    fi

    log_ok "Waybar configuration deployed."
}

deploy_rofi_config() {
    log_info "Deploying Rofi configuration..."

    local dest="${XDG_CONFIG_HOME}/rofi"
    mkdir -p "${dest}"

    deploy_config "rofi/config.rasi" "${dest}/config.rasi"

    # Deploy themes and scripts directories if they exist.
    if [[ -d "${REPO_ROOT}/rofi/themes" ]]; then
        deploy_config "rofi/themes" "${dest}/themes"
    fi

    if [[ -d "${REPO_ROOT}/rofi/scripts" ]]; then
        deploy_config "rofi/scripts" "${dest}/scripts"
        make_executable "${dest}/scripts"
    fi

    log_ok "Rofi configuration deployed."
}

deploy_dunst_config() {
    log_info "Deploying Dunst configuration..."

    local dest="${XDG_CONFIG_HOME}/dunst"
    mkdir -p "${dest}"

    deploy_config "dunst/dunstrc" "${dest}/dunstrc"

    log_ok "Dunst configuration deployed."
}

# =============================================================================
# Main
# =============================================================================

main() {
    layer_banner "Layer 3 — Desktop UI" "Waybar, Rofi, and Dunst"

    require_not_root
    require_layer 2

    # Install packages.
    log_section "Installing Layer 3 Packages"
    install_packages "Desktop UI Components" "${LAYER3_PACKAGES[@]}"

    # Deploy configs.
    log_section "Deploying Layer 3 Configuration"
    deploy_waybar_config
    deploy_rofi_config
    deploy_dunst_config

    # Summary.
    log_section "Layer 3 Installation Complete"
    echo -e "  ${COLOR_GREEN}${COLOR_BOLD}Layer 3 is complete.${COLOR_RESET}"
    echo ""
    echo -e "  ${COLOR_CYAN}Next steps:${COLOR_RESET}"
    echo -e "  1. Run  ${COLOR_BOLD}bash install/verify_layer3.sh${COLOR_RESET}  to verify."
    echo -e "  2. Reload Hyprland to see Waybar, or log out and back in."
    echo -e "  3. When ready, proceed to Layer 4: ${COLOR_BOLD}bash install/layer4.sh${COLOR_RESET}"
    echo ""
}

main "$@"
