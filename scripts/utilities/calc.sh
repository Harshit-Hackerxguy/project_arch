#!/usr/bin/env bash
# =============================================================================
# Script Name: calc.sh
# Description: Rofi calculator launcher using rofi-calc or python evaluator.
# Layer: Layer 9 — Automation & Productivity
# =============================================================================

set -euo pipefail

ROFI_THEME="${HOME}/.config/rofi/themes/cyber-minimal.rasi"

if rofi -show calc -modi calc -no-show-match -no-sort -theme "${ROFI_THEME}" 2>/dev/null; then
    exit 0
else
    # Fallback interactive bc/python calculator via dmenu
    expr=$(rofi -dmenu -i -p "  Calculate" -theme "${ROFI_THEME}" </dev/null)
    if [[ -n "${expr}" ]]; then
        res=$(python3 -c "from math import *; print(${expr})" 2>/dev/null || echo "Error in expression")
        if [[ "${res}" != "Error in expression" ]]; then
            printf "%s" "${res}" | wl-copy
            notify-send -u normal -a "Calculator" "  Result: ${res}" "Copied to clipboard."
        else
            notify-send -u critical -a "Calculator" "  Calculation Error" "Could not evaluate: ${expr}"
        fi
    fi
fi
