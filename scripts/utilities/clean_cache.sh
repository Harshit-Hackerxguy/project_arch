#!/usr/bin/env bash
# =============================================================================
# Script Name: clean_cache.sh
# Description: Cleans system and user cache directories safely.
# Layer: Layer 9 — Automation & Productivity
# =============================================================================

set -euo pipefail

log_clean() {
    echo "[$1] $2"
}

# 1. Clean pacman / AUR cache (keep last 2 versions)
if command -v paccache >/dev/null 2>&1; then
    log_clean "Pacman" "Cleaning old package cache..."
    sudo paccache -r || true
    sudo paccache -ruk0 || true
elif command -v paru >/dev/null 2>&1; then
    log_clean "AUR" "Cleaning paru cache..."
    paru -Sc --noconfirm || true
fi

# 2. Clean thumbnail cache older than 14 days
if [ -d "${HOME}/.cache/thumbnails" ]; then
    log_clean "Thumbnails" "Removing old thumbnail cache..."
    find "${HOME}/.cache/thumbnails" -type f -atime +14 -delete 2>/dev/null || true
fi

# 3. Clean generic user cache files older than 30 days
find "${HOME}/.cache" -maxdepth 2 -type f -atime +30 -delete 2>/dev/null || true

notify-send -u low -a "System Cleanup" "󰃢  Cache Cleaned" "Successfully freed cache space."
