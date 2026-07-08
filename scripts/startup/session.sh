#!/usr/bin/env bash
# =============================================================================
# Script Name: session.sh
# Description: Initializes Wayland session environment variables and services.
# Layer: Layer 9 — Automation & Productivity
# =============================================================================

set -euo pipefail

# 1. Import Wayland environment into systemd and dbus session buses
if command -v dbus-update-activation-environment >/dev/null 2>&1; then
    dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP QT_QPA_PLATFORMTHEME GTK_THEME XCURSOR_THEME XCURSOR_SIZE || true
fi

if command -v systemctl >/dev/null 2>&1; then
    systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP QT_QPA_PLATFORMTHEME GTK_THEME XCURSOR_THEME XCURSOR_SIZE || true
fi

# 2. Ensure wallpaper symlink exists or set default wallpaper if available
if [ ! -f "${HOME}/.config/wallpapers/current.png" ]; then
    if [ -d "${HOME}/Pictures/Wallpapers" ]; then
        default_wall=$(find "${HOME}/Pictures/Wallpapers" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" \) | head -n 1 || true)
        if [ -n "${default_wall}" ]; then
            ln -sf "${default_wall}" "${HOME}/.config/wallpapers/current.png"
        fi
    fi
fi

# 3. Apply GTK / Cursor settings to XSettings daemon if xsettingsd is present
if command -v xsettingsd >/dev/null 2>&1 && ! pgrep -x xsettingsd >/dev/null; then
    xsettingsd -c "${HOME}/.config/gtk-3.0/xsettingsd.conf" &
fi

exit 0
