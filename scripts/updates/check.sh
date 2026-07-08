#!/usr/bin/env bash
# =============================================================================
# Script Name: check.sh
# Description: Checks for system and AUR package updates (for Waybar & Dunst).
# Layer: Layer 9 — Automation & Productivity
# =============================================================================

set -euo pipefail

check_repo_updates() {
    if command -v checkupdates >/dev/null 2>&1; then
        checkupdates 2>/dev/null | wc -l
    else
        echo "0"
    fi
}

check_aur_updates() {
    if command -v paru >/dev/null 2>&1; then
        paru -Qua 2>/dev/null | wc -l
    elif command -v yay >/dev/null 2>&1; then
        yay -Qua 2>/dev/null | wc -l
    else
        echo "0"
    fi
}

case "${1:-waybar}" in
    "waybar")
        repo=$(check_repo_updates)
        aur=$(check_aur_updates)
        total=$(( repo + aur ))

        if (( total > 0 )); then
            printf '{"text": "󰚰 %d", "tooltip": "%d Official, %d AUR updates available", "class": "pending"}\n' "${total}" "${repo}" "${aur}"
        else
            printf '{"text": "", "tooltip": "System is up to date", "class": "updated"}\n'
        fi
        ;;
    "notify")
        repo=$(check_repo_updates)
        aur=$(check_aur_updates)
        total=$(( repo + aur ))

        if (( total > 0 )); then
            notify-send -u normal -a "System Updates" "󰚰  Updates Available" "${repo} Official and ${aur} AUR updates are ready to install."
        else
            notify-send -u low -a "System Updates" "󰄬  Up to Date" "No pending updates found."
        fi
        ;;
    *)
        echo "Usage: $0 [waybar|notify]" >&2
        exit 1
        ;;
esac
