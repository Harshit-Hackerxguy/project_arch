#!/usr/bin/env bash
# =============================================================================
# Script Name: file_manager.sh
# Description: Launches preferred terminal or GUI file manager cleanly.
# Layer: Layer 9 — Automation & Productivity
# =============================================================================

set -euo pipefail

TERMINAL="${TERMINAL:-kitty}"
TARGET="${1:-${HOME}}"

if command -v yazi >/dev/null 2>&1; then
    exec "${TERMINAL}" --class file-manager -e yazi "${TARGET}"
elif command -v ranger >/dev/null 2>&1; then
    exec "${TERMINAL}" --class file-manager -e ranger "${TARGET}"
elif command -v thunar >/dev/null 2>&1; then
    exec thunar "${TARGET}"
elif command -v nautilus >/dev/null 2>&1; then
    exec nautilus "${TARGET}"
else
    notify-send -u critical -a "File Manager" "Error" "No supported file manager (yazi/ranger/thunar/nautilus) found." >&2
    exit 1
fi
