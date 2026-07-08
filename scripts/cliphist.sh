#!/usr/bin/env bash
# =============================================================================
# Script Name: cliphist.sh
# Description: Delegates to modular clipboard script in utilities/.
# Layer: Layer 9 — Automation & Productivity
# =============================================================================

set -euo pipefail

SCRIPT_PATH="$(dirname "${BASH_SOURCE[0]}")/utilities/clipboard.sh"

if [ -x "${SCRIPT_PATH}" ]; then
    exec "${SCRIPT_PATH}" "$@"
else
    echo "Error: Modular clipboard script not found at ${SCRIPT_PATH}" >&2
    exit 1
fi
