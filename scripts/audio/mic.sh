#!/usr/bin/env bash
# =============================================================================
# Script Name: mic.sh
# Description: Microphone control and mute toggle with Dunst notifications.
# Layer: Layer 9 — Automation & Productivity
# =============================================================================

set -euo pipefail

send_notification() {
    local muted icon
    if command -v pamixer >/dev/null 2>&1; then
        muted=$(pamixer --default-source --get-mute)
    else
        muted=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q "MUTED" && echo "true" || echo "false")
    fi

    if [[ "${muted}" == "true" ]]; then
        icon="audio-input-microphone-muted"
        notify-send -u low -a "changeVolume" -r 9992 -i "${icon}" "  Microphone Muted"
    else
        icon="audio-input-microphone"
        notify-send -u normal -a "changeVolume" -r 9992 -i "${icon}" "  Microphone Active"
    fi
}

case "${1:-toggle}" in
    "toggle")
        if command -v pamixer >/dev/null 2>&1; then
            pamixer --default-source -t
        else
            wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        fi
        send_notification
        ;;
    "mute")
        if command -v pamixer >/dev/null 2>&1; then
            pamixer --default-source -m
        else
            wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 1
        fi
        send_notification
        ;;
    "unmute")
        if command -v pamixer >/dev/null 2>&1; then
            pamixer --default-source -u
        else
            wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0
        fi
        send_notification
        ;;
    "get")
        if command -v pamixer >/dev/null 2>&1; then
            if [[ "$(pamixer --default-source --get-mute)" == "true" ]]; then
                echo "Muted"
            else
                pamixer --default-source --get-volume
            fi
        else
            wpctl get-volume @DEFAULT_AUDIO_SOURCE@
        fi
        ;;
    *)
        echo "Usage: $0 [toggle|mute|unmute|get]" >&2
        exit 1
        ;;
esac
