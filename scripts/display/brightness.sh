#!/usr/bin/env bash
# =============================================================================
# Script Name: brightness.sh
# Description: Display brightness control with Dunst progress bar notifications.
# Layer: Layer 9 — Automation & Productivity
# =============================================================================

set -euo pipefail

send_notification() {
    local val icon
    val=$(brightnessctl -m | cut -d',' -f4 | tr -d '%')

    if (( val >= 70 )); then
        icon="display-brightness-high"
    elif (( val >= 30 )); then
        icon="display-brightness-medium"
    else
        icon="display-brightness-low"
    fi

    notify-send -u normal -a "changeBrightness" -r 9994 -h "int:value:${val}" -i "${icon}" "󰃠  Brightness: ${val}%"
}

case "${1:-}" in
    "up")
        brightnessctl set +5%
        send_notification
        ;;
    "down")
        brightnessctl set 5%-
        send_notification
        ;;
    "set")
        if [ -z "${2:-}" ]; then
            echo "Usage: $0 set <percentage>" >&2
            exit 1
        fi
        brightnessctl set "${2}%"
        send_notification
        ;;
    "get")
        brightnessctl -m | cut -d',' -f4 | tr -d '%'
        ;;
    *)
        echo "Usage: $0 [up|down|set|get]" >&2
        exit 1
        ;;
esac
