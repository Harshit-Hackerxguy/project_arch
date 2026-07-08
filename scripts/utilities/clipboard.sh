#!/usr/bin/env bash
# =============================================================================
# Script Name: clipboard.sh
# Description: Modular clipboard manager using cliphist, wl-clipboard, Rofi.
# Layer: Layer 9 — Automation & Productivity
# =============================================================================

set -euo pipefail

ROFI_THEME="${HOME}/.config/rofi/themes/cyber-minimal.rasi"

case "${1:-show}" in
    "show"|"list")
        if ! command -v cliphist >/dev/null 2>&1; then
            notify-send -u critical -a "Clipboard" "Error" "cliphist is not installed."
            exit 1
        fi
        cliphist list | rofi -dmenu -i -p "󰅍  Clipboard" -theme "${ROFI_THEME}" | cliphist decode | wl-copy
        ;;
    "clear"|"wipe")
        cliphist wipe
        notify-send -u low -a "Clipboard" "󰅍  Clipboard History" "Clipboard history wiped clean."
        ;;
    "delete")
        item=$(cliphist list | rofi -dmenu -i -p "󰆴  Delete Item" -theme "${ROFI_THEME}")
        if [[ -n "${item}" ]]; then
            echo "${item}" | cliphist delete
            notify-send -u low -a "Clipboard" "󰆴  Item Deleted" "Removed from clipboard history."
        fi
        ;;
    *)
        echo "Usage: $0 [show|clear|delete]" >&2
        exit 1
        ;;
esac
