#!/usr/bin/env bash
# =============================================================================
# Script Name: volume.sh
# Description: Delegates to modular volume script in audio/.
# Layer: Layer 9 — Automation & Productivity
# =============================================================================

set -euo pipefail

SCRIPT_PATH="$(dirname "${BASH_SOURCE[0]}")/audio/volume.sh"

if [ -x "${SCRIPT_PATH}" ]; then
    exec "${SCRIPT_PATH}" "$@"
else
    echo "Error: Modular volume script not found at ${SCRIPT_PATH}" >&2
    exit 1
fi
