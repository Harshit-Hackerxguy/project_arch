#!/usr/bin/env bash
# =============================================================================
# Script Name: wallpaper.sh
# Description: Sets wallpaper using swww or swaybg, updates previews & state.
# Layer: Layer 9 — Automation & Productivity
# =============================================================================

set -euo pipefail

WALL_DIR="${HOME}/Pictures/Wallpapers"
PREVIEW_DIR="${WALL_DIR}/previews"
CURRENT_SYMLINK="${HOME}/.config/wallpapers/current.png"

mkdir -p "${WALL_DIR}" "${PREVIEW_DIR}" "${HOME}/.config/wallpapers"

set_wallpaper() {
    local target="$1"
    if [[ ! -f "${target}" ]]; then
        echo "Error: Wallpaper file not found: ${target}" >&2
        exit 1
    fi

    # Update current symlink for Hyprlock and desktop consistency
    ln -sf "${target}" "${CURRENT_SYMLINK}"

    if command -v swww >/dev/null 2>&1; then
        if ! pgrep -x swww-daemon >/dev/null; then
            swww-daemon &
            sleep 0.5
        fi
        swww img "${target}" --transition-type wipe --transition-angle 30 --transition-step 90 --transition-fps 60
    elif command -v swaybg >/dev/null 2>&1; then
        pkill -x swaybg 2>/dev/null || true
        swaybg -m fill -i "${target}" &
    else
        echo "Warning: Neither swww nor swaybg found. Wallpaper symlink updated." >&2
    fi

    notify-send -u low -a "Wallpaper" -i "${target}" "󰸿  Wallpaper Updated" "$(basename "${target}")"
}

case "${1:-}" in
    "set")
        if [[ -z "${2:-}" ]]; then
            echo "Usage: $0 set <path-to-image>" >&2
            exit 1
        fi
        set_wallpaper "${2}"
        ;;
    "get")
        readlink -f "${CURRENT_SYMLINK}" 2>/dev/null || echo "None"
        ;;
    *)
        echo "Usage: $0 [set <image>|get]" >&2
        exit 1
        ;;
esac
