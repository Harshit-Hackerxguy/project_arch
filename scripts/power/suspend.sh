#!/usr/bin/env bash
# =============================================================================
# Script Name: suspend.sh
# Description: Prepares system and triggers sleep/suspend cleanly.
# Layer: Layer 8 — Session, Lock Screen & Power Management
# =============================================================================

set -euo pipefail

# 1. Pause any active media playback
if command -v playerctl >/dev/null 2>&1; then
    playerctl pause -a 2>/dev/null || true
fi

# 2. Lock the session before sleeping
if command -v loginctl >/dev/null 2>&1; then
    loginctl lock-session
elif [ -f "${HOME}/.config/scripts/power/lock.sh" ]; "${HOME}/.config/scripts/power/lock.sh" &
fi

# Small delay to ensure lock screen surface is mapped by compositor
sleep 0.5

# 3. Suspend system via systemctl
exec systemctl suspend
