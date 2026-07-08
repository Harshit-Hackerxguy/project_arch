#!/usr/bin/env bash
# =============================================================================
# Script Name: media.sh
# Description: Media playback controller using playerctl with notifications.
# Layer: Layer 9 — Automation & Productivity
# =============================================================================

set -euo pipefail

if ! command -v playerctl >/dev/null 2>&1; then
    echo "Error: playerctl is required for media controls." >&2
    exit 1
fi

send_notification() {
    local status artist title icon
    status=$(playerctl status 2>/dev/null || echo "Stopped")
    artist=$(playerctl metadata artist 2>/dev/null || echo "Unknown Artist")
    title=$(playerctl metadata title 2>/dev/null || echo "No Track Playing")

    if [[ "${status}" == "Playing" ]]; then
        icon="media-playback-start"
        notify-send -u low -a "Media" -r 9991 -i "${icon}" "󰐊  ${title}" "${artist}"
    elif [[ "${status}" == "Paused" ]]; then
        icon="media-playback-pause"
        notify-send -u low -a "Media" -r 9991 -i "${icon}" "󰏤  ${title}" "${artist}"
    fi
}

case "${1:-status}" in
    "play-pause"|"toggle")
        playerctl play-pause
        send_notification
        ;;
    "next")
        playerctl next
        send_notification
        ;;
    "prev"|"previous")
        playerctl previous
        send_notification
        ;;
    "stop")
        playerctl stop
        notify-send -u low -a "Media" -r 9991 -i "media-playback-stop" "󰓛  Playback Stopped" ""
        ;;
    "status")
        playerctl status 2>/dev/null || echo "Stopped"
        ;;
    *)
        echo "Usage: $0 [play-pause|next|prev|stop|status]" >&2
        exit 1
        ;;
esac
