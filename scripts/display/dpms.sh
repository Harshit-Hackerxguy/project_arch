#!/usr/bin/env bash
# =============================================================================
# Script Name: dpms.sh
# Description: Controls monitor power states (DPMS) via Hyprland IPC.
# Layer: Layer 8 — Session, Lock Screen & Power Management
# =============================================================================

set -euo pipefail

case "${1:-toggle}" in
    "on")
        hyprctl dispatch dpms on
        ;;
    "off")
        hyprctl dispatch dpms off
        ;;
    "toggle")
        hyprctl dispatch dpms toggle
        ;;
    *)
        echo "Usage: $0 [on|off|toggle]" >&2
        exit 1
        ;;
esac
