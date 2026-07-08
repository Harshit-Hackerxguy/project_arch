#!/usr/bin/env bash
# =============================================================================
# Script Name: screenshot.sh
# Description: Modular screenshot utility using grim, slurp, swappy, wl-copy.
# Layer: Layer 9 — Automation & Productivity
# =============================================================================

set -euo pipefail

SAVE_DIR="${HOME}/Pictures/Screenshots"
mkdir -p "${SAVE_DIR}"

TIMESTAMP="$(date '+%Y%m%d_%H%M%S')"
FILENAME="${SAVE_DIR}/screenshot_${TIMESTAMP}.png"

send_notification() {
    local file="$1"
    local mode="$2"
    notify-send -u normal -a "Screenshot" -i "${file}" "󰹑  Screenshot Saved" "Mode: ${mode}\nSaved to ${file} and copied to clipboard."
    if command -v canberra-gtk-play >/dev/null 2>&1; then
        canberra-gtk-play -i screen-capture -d "screenshot" 2>/dev/null &
    fi
}

case "${1:-screen}" in
    "screen"|"full")
        grim "${FILENAME}"
        wl-copy < "${FILENAME}"
        send_notification "${FILENAME}" "Full Screen"
        ;;
    "area"|"region")
        grim -g "$(slurp -d -c 38BDF8 -w 2)" "${FILENAME}"
        wl-copy < "${FILENAME}"
        send_notification "${FILENAME}" "Selected Region"
        ;;
    "window")
        win_geom=$(hyprctl -j activewindow | jq -r '"\(.at[0]),\(.at[1]) \(..size[0]|numbers)x\(..size[1]|numbers)"' 2>/dev/null || slurp)
        grim -g "${win_geom}" "${FILENAME}"
        wl-copy < "${FILENAME}"
        send_notification "${FILENAME}" "Active Window"
        ;;
    "edit")
        grim -g "$(slurp -d -c 38BDF8 -w 2)" - | swappy -f -
        ;;
    "delay"|"timer")
        delay="${2:-5}"
        notify-send -u low -a "Screenshot" "󰹑  Timer Started" "Taking screenshot in ${delay} seconds..."
        sleep "${delay}"
        grim "${FILENAME}"
        wl-copy < "${FILENAME}"
        send_notification "${FILENAME}" "Delayed (${delay}s)"
        ;;
    *)
        echo "Usage: $0 [screen|area|window|edit|delay <seconds>]" >&2
        exit 1
        ;;
esac
