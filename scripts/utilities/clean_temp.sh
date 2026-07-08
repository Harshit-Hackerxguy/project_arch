#!/usr/bin/env bash
# =============================================================================
# Script Name: clean_temp.sh
# Description: Cleans temporary files from /tmp and user state directories.
# Layer: Layer 9 — Automation & Productivity
# =============================================================================

set -euo pipefail

# 1. Clean user temporary files in /tmp older than 3 days
find /tmp -maxdepth 1 -user "$(whoami)" -type f -mtime +3 -delete 2>/dev/null || true

# 2. Clean old project logs or state files older than 7 days
if [ -d "${HOME}/.local/state/project_arch" ]; then
    find "${HOME}/.local/state/project_arch" -type f -mtime +7 -delete 2>/dev/null || true
fi

# 3. Clean crash dumps or old core files
find "${HOME}" -maxdepth 2 -name "core.*" -type f -mtime +3 -delete 2>/dev/null || true

notify-send -u low -a "System Cleanup" "󰃢  Temp Files Cleaned" "Temporary files older than 3 days removed."
