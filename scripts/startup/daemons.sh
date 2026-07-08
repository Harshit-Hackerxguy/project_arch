#!/usr/bin/env bash
# =============================================================================
# Script Name: daemons.sh
# Description: Launches required background services idempotently.
# Layer: Layer 9 — Automation & Productivity
# =============================================================================

set -euo pipefail

launch_once() {
    local proc_name="${1:?Process name required}"
    shift
    local cmd=("$@")

    if ! pgrep -x "${proc_name}" >/dev/null && ! pgrep -f "${proc_name}" >/dev/null; then
        "${cmd[@]}" &
    fi
}

# 1. Notification Daemon (Dunst)
if ! pgrep -x dunst >/dev/null; then
    dunst -config "${HOME}/.config/dunst/dunstrc" &
fi

# 2. Status Bar (Waybar)
if ! pgrep -x waybar >/dev/null; then
    waybar -c "${HOME}/.config/waybar/config.jsonc" -s "${HOME}/.config/waybar/style.css" &
fi

# 3. Clipboard Manager (wl-clipboard + cliphist watch)
if ! pgrep -f "cliphist store" >/dev/null; then
    wl-paste --type text --watch cliphist store &
    wl-paste --type image --watch cliphist store &
fi

# 4. Polkit Authentication Agent
if ! pgrep -f "polkit-.*-authentication-agent" >/dev/null; then
    for polkit in \
        /usr/lib/polkit-kde-authentication-agent-1 \
        /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 \
        /usr/libexec/polkit-gnome-authentication-agent-1 \
        /usr/lib/lxqt-policykit/lxqt-policykit-agent; do
        if [[ -x "${polkit}" ]]; then
            "${polkit}" &
            break
        fi
    done
fi

# 5. Network Applet
launch_once "nm-applet" nm-applet --indicator

# 6. Bluetooth Applet
launch_once "blueman-applet" blueman-applet

# 7. Idle Daemon (Hypridle)
if command -v hypridle >/dev/null 2>&1 && ! pgrep -x hypridle >/dev/null; then
    hypridle -c "${HOME}/.config/hypr/hypridle.conf" &
fi

# 8. Wallpaper Daemon (swww or swaybg)
if command -v swww >/dev/null 2>&1; then
    if ! pgrep -x swww-daemon >/dev/null; then
        swww-daemon &
        sleep 0.5
    fi
    if [ -f "${HOME}/.config/wallpapers/current.png" ]; then
        swww img "${HOME}/.config/wallpapers/current.png" --transition-type none 2>/dev/null || true
    fi
elif command -v swaybg >/dev/null 2>&1 && ! pgrep -x swaybg >/dev/null; then
    if [ -f "${HOME}/.config/wallpapers/current.png" ]; then
        swaybg -m fill -i "${HOME}/.config/wallpapers/current.png" &
    fi
fi

exit 0
