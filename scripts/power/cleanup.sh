#!/usr/bin/env bash
# =============================================================================
# Script Name: cleanup.sh
# Description: Cleans up session background processes, temp files, and sockets.
# Layer: Layer 8 — Session, Lock Screen & Power Management
# =============================================================================

set -euo pipefail

# 1. Terminate background UI daemons cleanly
for proc in dunst waybar rofi cliphist wl-paste swww-daemon swaybg; do
    if pgrep -x "${proc}" >/dev/null 2>&1; then
        pkill -TERM -x "${proc}" 2>/dev/null || true
    fi
done

# 2. Clean up stale SSH agent sockets or temporary IPC files in /tmp
find /tmp -maxdepth 1 -type s -user "$(whoami)" -delete 2>/dev/null || true
find /tmp -maxdepth 1 -type f -name "hypr*" -user "$(whoami)" -delete 2>/dev/null || true

# 3. Flush filesystem buffers to disk to prevent data loss before power events
sync || true

exit 0
