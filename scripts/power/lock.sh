#!/usr/bin/env bash
# =============================================================================
# Script Name: lock.sh
# Description: Idempotent screen locking utility for Hyprland.
# Layer: Layer 8 — Session, Lock Screen & Power Management
# =============================================================================

set -euo pipefail

if pgrep -x hyprlock >/dev/null; then
    exit 0
fi

if command -v hyprlock >/dev/null; then
    exec hyprlock
elif command -v swaylock >/dev/null; then
    exec swaylock
else
    notify-send -u critical -a "Lock Screen" "󰌾  Error" "No compatible screen locker (hyprlock/swaylock) found." >&2
    exit 1
fi
