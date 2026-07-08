#!/usr/bin/env bash
# =============================================================================
# Script Name: status.sh
# Description: Diagnoses network connectivity, latency, and VPN status.
# Layer: Layer 9 — Automation & Productivity
# =============================================================================

set -euo pipefail

case "${1:-check}" in
    "check")
        if ping -c 1 -W 2 1.1.1.1 >/dev/null 2>&1 || ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
            latency=$(ping -c 1 -W 2 1.1.1.1 | grep 'time=' | awk -F'time=' '{print $2}' | awk '{print $1}' || echo "N/A")
            echo "Online (${latency} ms)"
        else
            echo "Offline"
        fi
        ;;
    "vpn")
        vpn=$(nmcli -t -f name,type con show --active | grep 'vpn' | cut -d':' -f1 || echo "")
        if [[ -n "${vpn}" ]]; then
            echo "VPN: ${vpn}"
        else
            echo "VPN: Disconnected"
        fi
        ;;
    "notify")
        status=$("${BASH_SOURCE[0]}" check)
        vpn=$("${BASH_SOURCE[0]}" vpn)
        ip=$(curl -s --max-time 3 https://ifconfig.me || echo "Unknown IP")
        notify-send -u normal -a "Network" "󰈀   Network Status" "Status: ${status}\n${vpn}\nExternal IP: ${ip}"
        ;;
    *)
        echo "Usage: $0 [check|vpn|notify]" >&2
        exit 1
        ;;
esac
