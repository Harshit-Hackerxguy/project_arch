#!/usr/bin/env bash
# =============================================================================
# Script Name: update.sh
# Description: Helper script to launch system update in a dedicated terminal.
# Layer: Layer 9 — Automation & Productivity
# =============================================================================

set -euo pipefail

TERMINAL="${TERMINAL:-kitty}"

update_cmd="echo '=== Starting System Update ===' && "
if command -v paru >/dev/null 2>&1; then
    update_cmd+="paru -Syu --noconfirm"
elif command -v yay >/dev/null 2>&1; then
    update_cmd+="yay -Syu --noconfirm"
else
    update_cmd+="sudo pacman -Syu"
fi
update_cmd+=" && echo '=== Update Complete ===' && read -p 'Press Enter to exit...' -r"

if [[ -t 0 ]]; then
    eval "${update_cmd}"
else
    exec "${TERMINAL}" --class update-helper -e bash -c "${update_cmd}"
fi
