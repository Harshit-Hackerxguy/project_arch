#!/usr/bin/env bash
# =============================================================================
# Script Name: rotate.sh
# Description: Random wallpaper rotation script from ~/Pictures/Wallpapers.
# Layer: Layer 9 — Automation & Productivity
# =============================================================================

set -euo pipefail

WALL_DIR="${HOME}/Pictures/Wallpapers"

if [[ ! -d "${WALL_DIR}" ]]; then
    echo "Error: Wallpaper directory ${WALL_DIR} does not exist." >&2
    exit 1
fi

# Find all image files
mapfile -t images < <(find "${WALL_DIR}" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \))

if (( ${#images[@]} == 0 )); then
    echo "Error: No image files found in ${WALL_DIR}." >&2
    exit 1
fi

# Select random image
random_img="${images[RANDOM % ${#images[@]}]}"

if [ -x "$(dirname "${BASH_SOURCE[0]}")/wallpaper.sh" ]; then
    "$(dirname "${BASH_SOURCE[0]}")/wallpaper.sh" set "${random_img}"
else
    echo "Error: wallpaper.sh script not executable or found." >&2
    exit 1
fi
