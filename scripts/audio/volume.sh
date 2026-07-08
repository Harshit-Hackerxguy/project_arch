#!/usr/bin/env bash
# =============================================================================
# Script Name: volume.sh
# Description: Modular audio volume control with Dunst notifications and sounds.
# Layer: Layer 9 — Automation & Productivity
# =============================================================================

set -euo pipefail

send_notification() {
    local vol muted icon
    if command -v pamixer >/dev/null 2>&1; then
        vol=$(pamixer --get-volume)
        muted=$(pamixer --get-mute)
    else
        vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}')
        muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q "MUTED" && echo "true" || echo "false")
    fi

    if [[ "${muted}" == "true" ]]; then
        icon="audio-volume-muted"
        notify-send -u low -a "changeVolume" -r 9993 -i "${icon}" "󰖁  Volume Muted"
    else
        if (( vol >= 70 )); then
            icon="audio-volume-high"
        elif (( vol >= 30 )); then
            icon="audio-volume-medium"
        else
            icon="audio-volume-low"
        fi
        notify-send -u normal -a "changeVolume" -r 9993 -h "int:value:${vol}" -i "${icon}" "  Volume: ${vol}%"
    fi

    if command -v canberra-gtk-play >/dev/null 2>&1 && [[ "${muted}" != "true" ]]; then
        canberra-gtk-play -i audio-volume-change -d "changeVolume" 2>/dev/null &
    fi
}

case "${1:-}" in
    "up")
        if command -v pamixer >/dev/null 2>&1; then
            pamixer -u -i 5
        else
            wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
            wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+
        fi
        send_notification
        ;;
    "down")
        if command -v pamixer >/dev/null 2>&1; then
            pamixer -u -d 5
        else
            wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
            wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        fi
        send_notification
        ;;
    "mute")
        if command -v pamixer >/dev/null 2>&1; then
            pamixer -t
        else
            wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        fi
        send_notification
        ;;
    "get")
        if command -v pamixer >/dev/null 2>&1; then
            if [[ "$(pamixer --get-mute)" == "true" ]]; then
                echo "Muted"
            else
                pamixer --get-volume
            fi
        else
            wpctl get-volume @DEFAULT_AUDIO_SINK@
        fi
        ;;
    *)
        echo "Usage: $0 [up|down|mute|get]" >&2
        exit 1
        ;;
esac
