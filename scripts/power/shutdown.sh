#!/usr/bin/env bash
# =============================================================================
# Script Name: shutdown.sh
# Description: Gracefully cleans up session and powers off system.
# Layer: Layer 8 — Session, Lock Screen & Power Management
# =============================================================================

set -euo pipefail

if [ -x "${HOME}/.config/scripts/power/cleanup.sh" ]; then
    "${HOME}/.config/scripts/power/cleanup.sh" || true
fi

exec systemctl poweroff
