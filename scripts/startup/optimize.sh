#!/usr/bin/env bash
# =============================================================================
# Script Name: optimize.sh
# Description: Optimizes runtime kernel variables, cache, and systemd behavior.
# Layer: Layer 10 — Final Polish
# =============================================================================

set -euo pipefail

# 1. Optimize virtual memory filesystem cache parameters (if writable / root)
if [[ -w /proc/sys/vm/vfs_cache_pressure ]]; then
    echo 50 > /proc/sys/vm/vfs_cache_pressure 2>/dev/null || true
fi

if [[ -w /proc/sys/vm/swappiness ]]; then
    echo 10 > /proc/sys/vm/swappiness 2>/dev/null || true
fi

# 2. Vacuum systemd journal to prevent excessive disk IO on boot
if command -v journalctl >/dev/null 2>&1; then
    journalctl --vacuum-time=7d --vacuum-size=500M 2>/dev/null || true
fi

# 3. Clean stale application lock files that slow down application launches
find "${HOME}/.config" -name "*.lock" -type f -delete 2>/dev/null || true
find "${HOME}/.cache" -name "*.lock" -type f -delete 2>/dev/null || true

# 4. Pre-warm icon theme cache in background if gtk-update-icon-cache exists
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    for icon_dir in "${HOME}/.local/share/icons"/* /usr/share/icons/Papirus*; do
        if [ -d "${icon_dir}" ] && [ -w "${icon_dir}" ]; then
            gtk-update-icon-cache -f -t "${icon_dir}" 2>/dev/null || true
        fi
    done &
fi

exit 0
