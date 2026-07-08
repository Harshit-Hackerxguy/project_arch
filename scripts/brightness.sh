#!/usr/bin/env bash
# =============================================================================
# Script Name: brightness.sh
# Description: Delegates to modular brightness script in display/.
# Layer: Layer 9 — Automation & Productivity
# =============================================================================

set -euo pipefail

SCRIPT_PATH="$(dirname "${BASH_SOURCE[0]}")/display/brightness.sh"

if [ -x "${SCRIPT_PATH}" ]; then
    exec "${SCRIPT_PATH}" "$@"
else
    echo "Error: Modular brightness script not found at ${SCRIPT_PATH}" >&2
    exit 1
fi
