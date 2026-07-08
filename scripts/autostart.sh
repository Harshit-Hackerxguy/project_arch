#!/usr/bin/env bash
# =============================================================================
# Script Name: autostart.sh
# Description: Main autostart orchestrator (delegates to startup/ scripts).
# Layer: Layer 9 — Automation & Productivity
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Initialize session environment and wallpaper state
if [ -x "${SCRIPT_DIR}/startup/session.sh" ]; then
    "${SCRIPT_DIR}/startup/session.sh"
fi

# 2. Launch background daemons idempotently
if [ -x "${SCRIPT_DIR}/startup/daemons.sh" ]; then
    exec "${SCRIPT_DIR}/startup/daemons.sh"
else
    echo "Error: daemons.sh not found in ${SCRIPT_DIR}/startup/" >&2
    exit 1
fi
