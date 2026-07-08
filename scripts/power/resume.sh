#!/usr/bin/env bash
# =============================================================================
# Script Name: resume.sh
# Description: Handles post-sleep/resume recovery tasks.
# Layer: Layer 8 — Session, Lock Screen & Power Management
# =============================================================================

set -euo pipefail

# 1. Ensure display DPMS is turned back on
if command -v hyprctl >/dev/null 2>&1; then
    hyprctl dispatch dpms on 2>/dev/null || true
fi

# 2. Refresh Waybar to prevent stale status or frozen clocks
if pgrep -x waybar >/dev/null; then
    pkill -SIGUSR2 waybar 2>/dev/null || true
fi

# 3. Re-verify network connectivity or restart nm-applet if unresponsive
if command -v nm-applet >/dev/null 2>&1 && ! pgrep -x nm-applet >/dev/null; then
    nm-applet --indicator &
fi

exit 0
