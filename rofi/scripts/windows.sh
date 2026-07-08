#!/usr/bin/env bash
# =============================================================================
# Script Name: windows.sh
# Description: Launches Rofi in window switcher mode.
# Layer: Layer 6 — Rofi
# =============================================================================

set -euo pipefail

ROFI_CONFIG="${HOME}/.config/rofi/config.rasi"
ROFI_THEME="${HOME}/.config/rofi/themes/cyber-minimal.rasi"

if pgrep -x rofi >/dev/null; then
    killall -q rofi
    exit 0
fi

exec rofi \
    -show window \
    -config "${ROFI_CONFIG}" \
    -theme "${ROFI_THEME}"
