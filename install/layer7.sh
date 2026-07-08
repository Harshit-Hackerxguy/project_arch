#!/usr/bin/env bash
# =============================================================================
# Script Name: layer7.sh
# Description: Layer 7 installer — Utility scripts, maintenance scripts,
#              permissions, and system optimizations.
#
#              Installs and configures:
#                - Deploys all scripts/ to ~/.config/scripts/
#                - Sets executable permissions
#                - Installs maintenance dependencies
#                - Applies system performance optimizations
#
# Usage:       bash install/layer7.sh
# Requires:    Layer 6 must be installed first.
#
# Author:      project_arch contributors
# Layer:       Layer 7 — Utilities & Maintenance
# =============================================================================

set -euo pipefail

CURRENT_LAYER="Layer 7"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# =============================================================================
# Package Definitions
# =============================================================================

readonly LAYER7_PACKAGES=(
    "cronie"                      # Cron daemon for scheduled tasks
    "pacman-contrib"              # paccache, checkupdates, and other pacman tools
    "imagemagick"                 # Image manipulation (used by scripts)
    "tesseract"                   # OCR engine (used by ocr.sh)
    "tesseract-data-eng"          # English language data for Tesseract
    "bc"                          # Calculator (used by calc.sh)
)

# =============================================================================
# Script Deployment
# =============================================================================

deploy_scripts() {
    log_section "Deploying Utility Scripts"

    local scripts_src="${REPO_ROOT}/scripts"
    local scripts_dest="${XDG_CONFIG_HOME}/scripts"

    if [[ ! -d "${scripts_src}" ]]; then
        log_warn "scripts/ directory not found in repo — skipping."
        return 0
    fi

    mkdir -p "${scripts_dest}"

    # Deploy the entire scripts tree using rsync for efficiency.
    if command_exists rsync; then
        rsync -a --backup --suffix="${BACKUP_SUFFIX}" "${scripts_src}/" "${scripts_dest}/"
        log_ok "Scripts deployed via rsync: ${scripts_src} → ${scripts_dest}"
    else
        cp -r "${scripts_src}/." "${scripts_dest}/"
        log_ok "Scripts deployed via cp: ${scripts_src} → ${scripts_dest}"
    fi

    # Set executable permissions on all .sh files.
    make_executable "${scripts_dest}"
}

# =============================================================================
# Desktop Configuration Deployment
# =============================================================================

deploy_desktop_configs() {
    log_section "Deploying Desktop Configurations"

    local configs=(
        "hypr"
        "waybar"
        "kitty"
        "rofi"
        "dunst"
        "hyprpaper"
    )

    for conf in "${configs[@]}"; do
        if [[ -d "${REPO_ROOT}/${conf}" ]]; then
            mkdir -p "${XDG_CONFIG_HOME}/${conf}"
            cp -r "${REPO_ROOT}/${conf}/." "${XDG_CONFIG_HOME}/${conf}/"
            log_ok "Deployed configuration: ${conf} → ${XDG_CONFIG_HOME}/${conf}"
        fi
    done

    if [[ -f "${REPO_ROOT}/hyprpaper/hyprpaper.conf" ]]; then
        cp "${REPO_ROOT}/hyprpaper/hyprpaper.conf" "${XDG_CONFIG_HOME}/hyprpaper.conf"
    fi

    if [[ -f "${REPO_ROOT}/gtk/settings.ini" ]]; then
        mkdir -p "${XDG_CONFIG_HOME}/gtk-3.0" "${XDG_CONFIG_HOME}/gtk-4.0"
        cp "${REPO_ROOT}/gtk/settings.ini" "${XDG_CONFIG_HOME}/gtk-3.0/settings.ini"
        cp "${REPO_ROOT}/gtk/settings.ini" "${XDG_CONFIG_HOME}/gtk-4.0/settings.ini"
        log_ok "Deployed GTK settings.ini to ~/.config/gtk-3.0 and ~/.config/gtk-4.0"
    fi
}

# =============================================================================
# System Optimizations
# =============================================================================

configure_pacman_cleanup() {
    log_info "Configuring automatic pacman cache cleanup..."

    # Enable paccache timer to clean old package versions weekly.
    if command_exists paccache; then
        enable_system_service "paccache.timer" "Pacman cache cleanup timer"
    else
        log_warn "paccache not found — skipping cache cleanup timer."
    fi
}

configure_cron() {
    log_info "Enabling cron daemon..."

    enable_system_service "cronie.service" "Cron daemon"
}

apply_sysctl_optimizations() {
    log_info "Checking sysctl optimizations..."

    local sysctl_conf="/etc/sysctl.d/99-project-arch.conf"

    if [[ -f "${sysctl_conf}" ]]; then
        log_info "Sysctl optimizations already applied: ${sysctl_conf}"
        return 0
    fi

    log_info "Writing performance optimizations to ${sysctl_conf}..."

    sudo tee "${sysctl_conf}" > /dev/null <<'EOF'
# project_arch — Layer 7 System Optimizations
# Applied by: bash install/layer7.sh
#
# These settings are safe defaults that improve desktop responsiveness.

# Reduce swap usage (prefer RAM over swap for desktop workloads).
vm.swappiness = 10

# Increase inotify watchers (needed for file managers and IDEs).
fs.inotify.max_user_watches = 524288

# Increase max queued events (prevents inotify overflow under heavy I/O).
fs.inotify.max_queued_events = 32768

# Increase max user instances for inotify.
fs.inotify.max_user_instances = 1024
EOF

    # Apply immediately.
    sudo sysctl --system > /dev/null 2>&1
    log_ok "Sysctl optimizations applied."
}

# =============================================================================
# Permissions
# =============================================================================

fix_permissions() {
    log_info "Fixing permissions..."

    # Ensure ~/.local/bin scripts are executable.
    if [[ -d "${XDG_BIN_HOME}" ]]; then
        find "${XDG_BIN_HOME}" -type f -exec chmod +x {} \; 2>/dev/null
        log_ok "~/.local/bin permissions set."
    fi

    # Ensure config scripts are executable.
    if [[ -d "${XDG_CONFIG_HOME}/scripts" ]]; then
        make_executable "${XDG_CONFIG_HOME}/scripts"
    fi

    # Ensure repo scripts are executable (for direct repo usage).
    if [[ -d "${REPO_ROOT}/scripts" ]]; then
        make_executable "${REPO_ROOT}/scripts"
    fi
}

# =============================================================================
# Main
# =============================================================================

main() {
    layer_banner "Layer 7 — Utilities" "Scripts, maintenance, permissions, optimizations"

    require_not_root
    require_layer 6

    # Install packages.
    log_section "Installing Layer 7 Packages"
    install_packages "Maintenance Utilities" "${LAYER7_PACKAGES[@]}"

    # Deploy scripts.
    deploy_scripts

    # Deploy desktop configurations.
    deploy_desktop_configs

    # System optimizations.
    log_section "System Configuration"
    configure_pacman_cleanup
    configure_cron
    apply_sysctl_optimizations

    # Permissions.
    log_section "Fixing Permissions"
    fix_permissions

    # Summary.
    log_section "Layer 7 Installation Complete"
    echo -e "  ${COLOR_GREEN}${COLOR_BOLD}Layer 7 is complete.${COLOR_RESET}"
    echo ""
    echo -e "  ${COLOR_GREEN}${COLOR_BOLD}All layers (1–7) are now installed.${COLOR_RESET}"
    echo ""
    echo -e "  ${COLOR_CYAN}Final steps:${COLOR_RESET}"
    echo -e "  1. Run  ${COLOR_BOLD}bash install/verify_layer7.sh${COLOR_RESET}  to verify."
    echo -e "  2. Log out and back in to apply all changes."
    echo -e "  3. Enjoy your new Arch + Hyprland desktop."
    echo ""
}

main "$@"
