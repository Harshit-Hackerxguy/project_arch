#!/usr/bin/env bash
# =============================================================================
# Script Name: launcher.sh
# Description: Launches Rofi in application launcher (drun) mode.
# Layer: Layer 6 — Rofi
# =============================================================================

set -euo pipefail

ROFI_CONFIG="${HOME}/.config/rofi/config.rasi"
ROFI_THEME="${HOME}/.config/rofi/themes/cyber-minimal.rasi"

# If Rofi is already running, close it (toggle behavior)
if pgrep -x rofi >/dev/null; then
    killall -q rofi
    exit 0
fi

exec rofi \
    -show drun \
    -config "${ROFI_CONFIG}" \
    -theme "${ROFI_THEME}"
