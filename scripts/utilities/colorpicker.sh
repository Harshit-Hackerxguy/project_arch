#!/usr/bin/env bash
# =============================================================================
# Script Name: colorpicker.sh
# Description: Color picker using hyprpicker with clipboard & Dunst preview.
# Layer: Layer 9 — Automation & Productivity
# =============================================================================

set -euo pipefail

if ! command -v hyprpicker >/dev/null 2>&1; then
    notify-send -u critical -a "Color Picker" "Error" "hyprpicker is not installed." >&2
    exit 1
fi

color=$(hyprpicker -a -r)

if [[ -n "${color}" ]]; then
    # Generate a temporary colored square icon using ImageMagick if available
    icon_path="/tmp/color_preview_${color//\#/}.png"
    if command -v convert >/dev/null 2>&1; then
        convert -size 64x64 xc:"${color}" "${icon_path}" 2>/dev/null || true
    fi

    if [[ -f "${icon_path}" ]]; then
        notify-send -u normal -a "Color Picker" -i "${icon_path}" "󰏘  Color Picked" "${color} copied to clipboard."
    else
        notify-send -u normal -a "Color Picker" "󰏘  Color Picked" "${color} copied to clipboard."
    fi
fi
