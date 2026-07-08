#!/usr/bin/env bash
# =============================================================================
# Script Name: powermenu.sh
# Description: Cyber-Minimal Power Menu using Rofi (delegates to modular script).
# Layer: Layer 8 — Session, Lock Screen & Power Management
# =============================================================================

set -euo pipefail

SCRIPT_PATH="${HOME}/.config/scripts/power/powermenu.sh"

if [ -x "${SCRIPT_PATH}" ]; then
    exec "${SCRIPT_PATH}" "$@"
elif [ -f "$(dirname "${BASH_SOURCE[0]}")/../../scripts/power/powermenu.sh" ]; then
    exec bash "$(dirname "${BASH_SOURCE[0]}")/../../scripts/power/powermenu.sh" "$@"
else
    echo "Error: Modular powermenu.sh not found at ${SCRIPT_PATH}" >&2
    exit 1
fi
