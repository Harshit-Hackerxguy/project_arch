#!/usr/bin/env bash
# =============================================================================
# Script Name: profiles.sh
# Description: Power profile management using powerprofilesctl and Rofi.
# Layer: Layer 9 — Automation & Productivity
# =============================================================================

set -euo pipefail

ROFI_THEME="${HOME}/.config/rofi/themes/cyber-minimal.rasi"

if ! command -v powerprofilesctl >/dev/null 2>&1; then
    if [[ "${1:-}" == "waybar" ]]; then
        printf '{"text": "N/A", "tooltip": "powerprofilesctl not found"}\n'
    else
        echo "Error: powerprofilesctl is not installed." >&2
        exit 1
    fi
    exit 0
fi

case "${1:-menu}" in
    "get"|"status")
        powerprofilesctl get
        ;;
    "set")
        if [[ -z "${2:-}" ]]; then
            echo "Usage: $0 set <power-saver|balanced|performance>" >&2
            exit 1
        fi
        powerprofilesctl set "$2"
        notify-send -u normal -a "Power" "󰾆  Power Profile Updated" "Active profile: $2"
        ;;
    "waybar")
        profile=$(powerprofilesctl get)
        case "${profile}" in
            "performance")
                printf '{"text": "󰓅 Performance", "tooltip": "High CPU Performance", "class": "performance"}\n'
                ;;
            "power-saver")
                printf '{"text": "󰾆 Power Saver", "tooltip": "Battery Saving Mode", "class": "power-saver"}\n'
                ;;
            *)
                printf '{"text": "󰾅 Balanced", "tooltip": "Standard Balanced Mode", "class": "balanced"}\n'
                ;;
        esac
        ;;
    "menu")
        opt_perf="󰓅  Performance"
        opt_bal="󰾅  Balanced"
        opt_save="󰾆  Power Saver"

        current=$(powerprofilesctl get)
        prompt="󰾆  Profile (${current})"

        chosen=$(printf "%s\n%s\n%s" "${opt_perf}" "${opt_bal}" "${opt_save}" | rofi -dmenu -i -p "${prompt}" -theme "${ROFI_THEME}")

        case "${chosen}" in
            "${opt_perf}") "${BASH_SOURCE[0]}" set performance ;;
            "${opt_bal}") "${BASH_SOURCE[0]}" set balanced ;;
            "${opt_save}") "${BASH_SOURCE[0]}" set power-saver ;;
            *) exit 0 ;;
        esac
        ;;
    *)
        echo "Usage: $0 [get|set <profile>|waybar|menu]" >&2
        exit 1
        ;;
esac
