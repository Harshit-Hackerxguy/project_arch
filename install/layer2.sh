#!/usr/bin/env bash
# =============================================================================
# Script Name: layer2.sh
# Description: Layer 2 installer — Hyprland window manager and related tools.
#
#              Installs and configures:
#                - Hyprland (Wayland compositor)
#                - hyprlock (screen locker)
#                - hypridle (idle daemon)
#                - hyprpaper (wallpaper daemon)
#                - XDG Desktop Portal (screen sharing)
#                - PipeWire (audio stack)
#
#              Deploys configuration from the repo:
#                - hyprland.conf, hyprlock.conf, hypridle.conf
#                - autostart.conf
#                - monitor, keybinding, window rule, and env configs
#
# Usage:       bash install/layer2.sh
# Requires:    Layer 1 must be installed first.
#
# Author:      project_arch contributors
# Layer:       Layer 2 — Hyprland
# =============================================================================

set -euo pipefail

CURRENT_LAYER="Layer 2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# =============================================================================
# Package Definitions
# =============================================================================

readonly LAYER2_PACKAGES=(
    "hyprland"                    # Wayland compositor
    "hyprlock"                    # Screen locker for Hyprland
    "hypridle"                    # Idle management daemon
    "hyprpaper"                   # Wallpaper manager for Hyprland
    "xdg-desktop-portal-hyprland" # XDG portal backend for screen sharing
    "xdg-desktop-portal-gtk"      # GTK portal backend (file dialogs)
    "xdg-desktop-portal"          # Portal frontend interface
    "qt5-wayland"                 # Qt5 Wayland integration
    "qt6-wayland"                 # Qt6 Wayland integration
    "pipewire"                    # Modern audio/video server
    "pipewire-alsa"               # ALSA compatibility layer for PipeWire
    "pipewire-pulse"              # PulseAudio compatibility layer
    "pipewire-jack"               # JACK compatibility layer
    "wireplumber"                 # Session manager for PipeWire
    "grim"                        # Screenshot tool (Wayland)
    "slurp"                       # Region selection tool (Wayland)
    "wl-clipboard"                # Clipboard utilities for Wayland
    "cliphist"                    # Clipboard history manager
    "brightnessctl"               # Backlight control
    "playerctl"                   # Media player control
    "polkit-gnome"                # Polkit authentication agent (GUI)
)

readonly LAYER2_AUR_PACKAGES=(
    "hyprpicker"                  # Color picker for Hyprland
)

# =============================================================================
# Configuration Deployment
# =============================================================================

deploy_hyprland_config() {
    log_section "Deploying Hyprland Configuration"

    local hypr_dest="${XDG_CONFIG_HOME}/hypr"
    mkdir -p "${hypr_dest}"

    # Deploy all config files from the hypr/ directory in the repo.
    # Each file is deployed individually so we can back up selectively.
    local hypr_files=(
        "hyprlock.conf"
        "hypridle.conf"
        "autostart.conf"
    )

    for file in "${hypr_files[@]}"; do
        if [[ -f "${REPO_ROOT}/hypr/${file}" ]]; then
            deploy_config "hypr/${file}" "${hypr_dest}/${file}"
        else
            log_warn "Config not found in repo: hypr/${file} — skipping."
        fi
    done

    # Deploy hyprland.conf if it exists in the repo.
    if [[ -f "${REPO_ROOT}/hypr/hyprland.conf" ]]; then
        deploy_config "hypr/hyprland.conf" "${hypr_dest}/hyprland.conf"
    else
        log_warn "hypr/hyprland.conf not found in repo."
        log_warn "Hyprland will use its default config until you create one."
    fi

    # Deploy any additional .conf files (monitors, keybinds, rules, env, etc.)
    for conf_file in "${REPO_ROOT}"/hypr/*.conf; do
        [[ -f "${conf_file}" ]] || continue
        local basename
        basename="$(basename "${conf_file}")"

        # Skip files we already deployed above.
        case "${basename}" in
            hyprland.conf|hyprlock.conf|hypridle.conf|autostart.conf)
                continue
                ;;
        esac

        deploy_config "hypr/${basename}" "${hypr_dest}/${basename}"
    done

    log_ok "Hyprland configuration deployed."
}

# =============================================================================
# PipeWire Audio Setup
# =============================================================================

setup_pipewire() {
    log_section "Configuring PipeWire Audio"

    # Enable PipeWire user services.
    enable_user_service "pipewire.socket"   "PipeWire socket"
    enable_user_service "pipewire-pulse.socket" "PipeWire PulseAudio socket"
    enable_user_service "wireplumber"       "WirePlumber session manager"

    log_ok "PipeWire audio stack configured."
}

# =============================================================================
# Wallpaper Directory
# =============================================================================

setup_wallpapers() {
    log_info "Ensuring wallpaper directories exist..."

    mkdir -p "${HOME}/Pictures/Wallpapers"

    # Copy wallpapers from repo if they exist and the directory isn't empty.
    if [[ -d "${REPO_ROOT}/wallpapers" ]] && [[ -n "$(ls -A "${REPO_ROOT}/wallpapers" 2>/dev/null)" ]]; then
        local count=0
        for wallpaper in "${REPO_ROOT}"/wallpapers/*; do
            [[ -f "${wallpaper}" ]] || continue
            local dest="${HOME}/Pictures/Wallpapers/$(basename "${wallpaper}")"
            if [[ ! -f "${dest}" ]]; then
                cp "${wallpaper}" "${dest}"
                count=$(( count + 1 ))
            fi
        done
        if [[ "${count}" -gt 0 ]]; then
            log_ok "Copied ${count} wallpaper(s) to ~/Pictures/Wallpapers/"
        else
            log_info "All wallpapers already in place."
        fi
    else
        log_info "No wallpapers found in repo — add them to wallpapers/ later."
    fi
}

# =============================================================================
# Main
# =============================================================================

main() {
    layer_banner "Layer 2 — Hyprland" "Wayland compositor and desktop foundation"

    require_not_root

    # Validate Layer 1 is installed.
    require_layer 1

    # Install packages.
    log_section "Installing Layer 2 Packages"
    install_packages "Hyprland & Wayland Stack" "${LAYER2_PACKAGES[@]}"
    install_aur_packages "Hyprland AUR Tools" "${LAYER2_AUR_PACKAGES[@]}"

    # Deploy configs.
    deploy_hyprland_config

    # Audio.
    setup_pipewire

    # Wallpapers.
    setup_wallpapers

    # Summary.
    log_section "Layer 2 Installation Complete"
    echo -e "  ${COLOR_GREEN}${COLOR_BOLD}Layer 2 is complete.${COLOR_RESET}"
    echo ""
    echo -e "  ${COLOR_CYAN}Next steps:${COLOR_RESET}"
    echo -e "  1. Run  ${COLOR_BOLD}bash install/verify_layer2.sh${COLOR_RESET}  to verify."
    echo -e "  2. Log out and select Hyprland from your display manager."
    echo -e "  3. When ready, proceed to Layer 3: ${COLOR_BOLD}bash install/layer3.sh${COLOR_RESET}"
    echo ""
}

main "$@"
