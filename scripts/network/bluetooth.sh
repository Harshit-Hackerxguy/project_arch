#!/usr/bin/env bash
# =============================================================================
# Script Name: bluetooth.sh
# Description: Rofi-based Bluetooth controller using bluetoothctl / blueman.
# Layer: Layer 9 — Automation & Productivity
# =============================================================================

set -euo pipefail

ROFI_THEME="${HOME}/.config/rofi/themes/cyber-minimal.rasi"

case "${1:-menu}" in
    "toggle")
        state=$(bluetoothctl show | grep "Powered:" | awk '{print $2}' || echo "no")
        if [[ "${state}" == "yes" ]]; then
            bluetoothctl power off
            notify-send -u low -a "Bluetooth" "󰂲  Bluetooth Disabled" ""
        else
            bluetoothctl power on
            notify-send -u normal -a "Bluetooth" "  Bluetooth Enabled" ""
        fi
        ;;
    "status")
        if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
            connected=$(bluetoothctl info 2>/dev/null | grep "Name:" | awk -F': ' '{print $2}' || echo "")
            if [[ -n "${connected}" ]]; then
                echo "Connected: ${connected}"
            else
                echo "On (Disconnected)"
            fi
        else
            echo "Off"
        fi
        ;;
    "menu")
        if command -v blueman-manager >/dev/null 2>&1; then
            blueman-manager &
            exit 0
        fi

        toggle_opt="  Toggle Power"
        devices=$(bluetoothctl devices | awk '{$1=""; print substr($0,2)}')
        chosen=$(printf "%s\n%s" "${toggle_opt}" "${devices}" | rofi -dmenu -i -p "  Bluetooth" -theme "${ROFI_THEME}")

        if [[ -z "${chosen}" ]]; then
            exit 0
        elif [[ "${chosen}" == "${toggle_opt}" ]]; "${BASH_SOURCE[0]}" toggle
        else
            dev_name=$(echo "${chosen}" | awk '{print $NF}')
            mac=$(bluetoothctl devices | grep "${dev_name}" | awk '{print $2}' | head -n 1)
            if [[ -n "${mac}" ]]; then
                notify-send -u low -a "Bluetooth" "  Connecting..." "Connecting to ${dev_name}"
                bluetoothctl connect "${mac}"
            fi
        fi
        ;;
    *)
        echo "Usage: $0 [toggle|status|menu]" >&2
        exit 1
        ;;
esac
