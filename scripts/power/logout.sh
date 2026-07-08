#!/usr/bin/env bash
# =============================================================================
# Script Name: logout.sh
# Description: Gracefully terminates the Wayland desktop session.
# Layer: Layer 8 — Session, Lock Screen & Power Management
# =============================================================================

set -euo pipefail

# Perform pre-logout cleanup
if [ -x "${HOME}/.config/scripts/power/cleanup.sh" ]; then
    "${HOME}/.config/scripts/power/cleanup.sh" || true
fi

if command -v hyprctl >/dev/null 2>&1; then
    exec hyprctl dispatch exit
else
    exec loginctl terminate-user "$(whoami)"
fi
