#!/usr/bin/env bash
# =============================================================================
# Script Name: layer6.sh
# Description: Layer 6 installer — Applications, MIME defaults, XDG dirs,
#              and desktop entries.
#
#              Installs and configures:
#                - Daily-use applications (file manager, browser, media, etc.)
#                - MIME type associations
#                - XDG user directory integration
#                - Desktop entry overrides
#
# Usage:       bash install/layer6.sh
# Requires:    Layer 5 must be installed first.
#
# Author:      project_arch contributors
# Layer:       Layer 6 — Applications
# =============================================================================

set -euo pipefail

CURRENT_LAYER="Layer 6"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# =============================================================================
# Package Definitions
# =============================================================================

readonly LAYER6_PACKAGES=(
    # File management
    "thunar"                      # GTK file manager
    "thunar-volman"               # Thunar removable media manager
    "gvfs"                        # Virtual filesystem (trash, MTP, network)
    "gvfs-mtp"                    # MTP (Android) device support
    "tumbler"                     # Thumbnail generator for file managers
    "ffmpegthumbnailer"           # Video thumbnail generator

    # Web browser
    "firefox"                     # Mozilla Firefox

    # Media
    "mpv"                         # Lightweight media player
    "imv"                         # Minimal Wayland image viewer
    "eog"                         # GNOME image viewer (fallback)

    # Documents
    "evince"                      # PDF / document viewer
    "xdg-utils"                   # xdg-open, xdg-mime, etc.

    # Archive
    "file-roller"                 # Archive manager (GUI)

    # Clipboard / screenshots (dependencies for scripts)
    "wtype"                       # Wayland xdotool alternative
    "xdg-user-dirs"               # Manage XDG user directories
)

readonly LAYER6_AUR_PACKAGES=(
    # Add AUR applications here as needed.
    # Example: "google-chrome"
)

# =============================================================================
# MIME Type Configuration
# =============================================================================

configure_mime_defaults() {
    log_info "Configuring MIME type defaults..."

    local mimeapps="${XDG_CONFIG_HOME}/mimeapps.list"

    # Only write if the file does not exist — respect user customization.
    if [[ -f "${mimeapps}" ]]; then
        log_info "mimeapps.list already exists — preserving user settings."
        return 0
    fi

    cat > "${mimeapps}" <<'EOF'
[Default Applications]
# Web
text/html=firefox.desktop
x-scheme-handler/http=firefox.desktop
x-scheme-handler/https=firefox.desktop
x-scheme-handler/about=firefox.desktop
x-scheme-handler/unknown=firefox.desktop

# File manager
inode/directory=thunar.desktop

# Images
image/png=imv.desktop
image/jpeg=imv.desktop
image/gif=imv.desktop
image/webp=imv.desktop
image/svg+xml=imv.desktop
image/bmp=imv.desktop

# Video
video/mp4=mpv.desktop
video/x-matroska=mpv.desktop
video/webm=mpv.desktop
video/x-msvideo=mpv.desktop

# Audio
audio/mpeg=mpv.desktop
audio/flac=mpv.desktop
audio/ogg=mpv.desktop
audio/wav=mpv.desktop

# Documents
application/pdf=org.gnome.Evince.desktop

# Archives
application/zip=org.gnome.FileRoller.desktop
application/x-tar=org.gnome.FileRoller.desktop
application/gzip=org.gnome.FileRoller.desktop
application/x-7z-compressed=org.gnome.FileRoller.desktop

# Text
text/plain=nvim.desktop
text/x-shellscript=nvim.desktop
application/json=nvim.desktop
application/xml=nvim.desktop
EOF

    log_ok "MIME defaults written to ${mimeapps}"
}

# =============================================================================
# XDG User Directories
# =============================================================================

refresh_xdg_user_dirs() {
    log_info "Refreshing XDG user directories..."

    if command_exists xdg-user-dirs-update; then
        xdg-user-dirs-update
        log_ok "XDG user directories updated."
    else
        log_warn "xdg-user-dirs-update not found — skipping."
    fi
}

# =============================================================================
# Desktop Entry Overrides
# =============================================================================

setup_desktop_entries() {
    log_info "Setting up desktop entry overrides..."

    local entries_dir="${XDG_DATA_HOME}/applications"
    mkdir -p "${entries_dir}"

    # Create an nvim desktop entry if it doesn't exist.
    local nvim_entry="${entries_dir}/nvim.desktop"
    if [[ ! -f "${nvim_entry}" ]]; then
        cat > "${nvim_entry}" <<'EOF'
[Desktop Entry]
Type=Application
Name=Neovim
Comment=Edit text files
Exec=kitty -e nvim %F
Icon=nvim
Terminal=false
Categories=Utility;TextEditor;
MimeType=text/plain;text/x-shellscript;application/json;application/xml;
EOF
        log_ok "Neovim desktop entry created."
    else
        log_info "Neovim desktop entry already exists."
    fi

    # Update desktop database.
    if command_exists update-desktop-database; then
        update-desktop-database "${entries_dir}" 2>/dev/null || true
        log_ok "Desktop database updated."
    fi
}

# =============================================================================
# Main
# =============================================================================

main() {
    layer_banner "Layer 6 — Applications" "Apps, MIME defaults, XDG, desktop entries"

    require_not_root
    require_layer 5

    # Install packages.
    log_section "Installing Layer 6 Packages"
    install_packages "Applications" "${LAYER6_PACKAGES[@]}"

    if [[ ${#LAYER6_AUR_PACKAGES[@]} -gt 0 ]]; then
        install_aur_packages "AUR Applications" "${LAYER6_AUR_PACKAGES[@]}"
    fi

    # Configure MIME and XDG.
    log_section "Configuring Layer 6"
    configure_mime_defaults
    refresh_xdg_user_dirs
    setup_desktop_entries

    # Summary.
    log_section "Layer 6 Installation Complete"
    echo -e "  ${COLOR_GREEN}${COLOR_BOLD}Layer 6 is complete.${COLOR_RESET}"
    echo ""
    echo -e "  ${COLOR_CYAN}Next steps:${COLOR_RESET}"
    echo -e "  1. Run  ${COLOR_BOLD}bash install/verify_layer6.sh${COLOR_RESET}  to verify."
    echo -e "  2. Test: ${COLOR_BOLD}xdg-open ~/Downloads${COLOR_RESET} should open Thunar."
    echo -e "  3. When ready, proceed to Layer 7: ${COLOR_BOLD}bash install/layer7.sh${COLOR_RESET}"
    echo ""
}

main "$@"
