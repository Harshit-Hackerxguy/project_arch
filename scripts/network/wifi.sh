#!/usr/bin/env bash
# =============================================================================
# Script Name: wifi.sh
# Description: Rofi-based Wi-Fi management utility using NetworkManager (nmcli).
# Layer: Layer 9 — Automation & Productivity
# =============================================================================

set -euo pipefail

ROFI_THEME="${HOME}/.config/rofi/themes/cyber-minimal.rasi"

case "${1:-menu}" in
    "toggle")
        state=$(nmcli -f WIFI g | tail -n 1 | tr -d ' ')
        if [[ "${state}" == "enabled" ]]; then
            nmcli radio wifi off
            notify-send -u low -a "Network" "󰖪  Wi-Fi Disabled" ""
        else
            nmcli radio wifi on
            notify-send -u normal -a "Network" "   Wi-Fi Enabled" ""
        fi
        ;;
    "status")
        nmcli -t -f active,ssid,signal dev wifi | grep '^yes' | cut -d':' -f2 || echo "Disconnected"
        ;;
    "menu")
        if ! command -v nmcli >/dev/null 2>&1; then
            notify-send -u critical -a "Network" "Error" "NetworkManager (nmcli) not found."
            exit 1
        fi

        # Get list of SSIDs
        wifi_list=$(nmcli --fields IN-USE,SSID,SECURITY,BARS dev wifi list | sed 1d | sed 's/^ */ /g' | sort -u)
        toggle_opt="󰖪  Toggle Wi-Fi Radio"
        
        chosen=$(printf "%s\n%s" "${toggle_opt}" "${wifi_list}" | rofi -dmenu -i -p "   Wi-Fi" -theme "${ROFI_THEME}")

        if [[ -z "${chosen}" ]]; then
            exit 0
        elif [[ "${chosen}" == "${toggle_opt}" ]]; "${BASH_SOURCE[0]}" toggle
        else
            ssid=$(echo "${chosen}" | awk -F'  +' '{print $2}' | sed 's/^[ *]*//g')
            if [[ -n "${ssid}" ]]; then
                notify-send -u low -a "Network" "   Connecting..." "Attempting connection to ${ssid}"
                if nmcli dev wifi connect "${ssid}"; then
                    notify-send -u normal -a "Network" "   Connected" "Successfully connected to ${ssid}"
                else
                    notify-send -u critical -a "Network" "󰖪  Connection Failed" "Could not connect to ${ssid}"
                fi
            fi
        fi
        ;;
    *)
        echo "Usage: $0 [toggle|status|menu]" >&2
        exit 1
        ;;
esac
