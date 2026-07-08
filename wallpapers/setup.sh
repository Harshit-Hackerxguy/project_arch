#!/usr/bin/env bash
# =============================================================================
# Script Name: setup.sh
# Description: Initializes wallpaper directory structure and default symlink.
# Layer: Layer 10 — Final Polish
# =============================================================================

set -euo pipefail

WALL_DIR="${HOME}/Pictures/Wallpapers"
PREVIEW_DIR="${WALL_DIR}/previews"
SYMLINK="${HOME}/.config/wallpapers/current.png"

mkdir -p "${WALL_DIR}" "${PREVIEW_DIR}" "${HOME}/.config/wallpapers"

# 1. Look for existing wallpapers in project directory or ~/Pictures/Wallpapers
default_img=""
if [ -d "$(dirname "${BASH_SOURCE[0]}")" ]; then
    default_img=$(find "$(dirname "${BASH_SOURCE[0]}")" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" \) | head -n 1 || echo "")
fi

if [ -z "${default_img}" ]; then
    default_img=$(find "${WALL_DIR}" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" \) | head -n 1 || echo "")
fi

# 2. Set default wallpaper symlink if found
if [ -n "${default_img}" ] && [ -f "${default_img}" ]; then
    ln -sf "${default_img}" "${SYMLINK}"
    if [ -x "${HOME}/.config/scripts/wallpaper/wallpaper.sh" ]; then
        "${HOME}/.config/scripts/wallpaper/wallpaper.sh" set "${default_img}" || true
    fi
    echo "Default wallpaper initialized: ${default_img}"
else
    echo "No wallpaper images found. Create or drop images into ${WALL_DIR}"
fi

exit 0
