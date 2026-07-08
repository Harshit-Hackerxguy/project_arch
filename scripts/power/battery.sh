#!/usr/bin/env bash
# =============================================================================
# Script Name: battery.sh
# Description: Battery status check and low battery warning notifier.
# Layer: Layer 9 — Automation & Productivity
# =============================================================================

set -euo pipefail

bat_path=$(find /sys/class/power_supply/ -name "BAT*" | head -n 1)

if [[ -z "${bat_path}" ]]; then
    if [[ "${1:-}" == "waybar" ]]; then
        printf '{"text": "AC", "tooltip": "Desktop / AC Power", "class": "plugged"}\n'
    else
        echo "No battery found (AC Power)"
    fi
    exit 0
fi

status=$(cat "${bat_path}/status" 2>/dev/null || echo "Unknown")
capacity=$(cat "${bat_path}/capacity" 2>/dev/null || echo "0")
health=$(cat "${bat_path}/capacity_level" 2>/dev/null || echo "Normal")

case "${1:-check}" in
    "check")
        echo "Battery: ${capacity}% (${status}) - Health: ${health}"
        ;;
    "notify")
        if [[ "${status}" != "Charging" ]]; then
            if (( capacity <= 15 )); then
                notify-send -u critical -a "Power" -i "battery-empty" "󰂎  Battery Critical (${capacity}%)" "Plug in power adapter immediately to prevent sleep or shutdown."
                if command -v canberra-gtk-play >/dev/null 2>&1; then
                    canberra-gtk-play -i battery-empty -d "battery-critical" 2>/dev/null &
                fi
            elif (( capacity <= 30 )); then
                notify-send -u normal -a "Power" -i "battery-low" "󰁻  Battery Low (${capacity}%)" "Consider connecting power adapter soon."
            fi
        fi
        ;;
    "waybar")
        printf '{"text": "%d%%", "tooltip": "Status: %s\\nHealth: %s", "class": "%s"}\n' "${capacity}" "${status}" "${health}" "${status,,}"
        ;;
    *)
        echo "Usage: $0 [check|notify|waybar]" >&2
        exit 1
        ;;
esac
