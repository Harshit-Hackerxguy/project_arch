#!/usr/bin/env bash
# =============================================================================
# Script Name: verify_desktop.sh
# Description: Post-installation verification for Layers 8–10.
# Layer: Final Validation
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALIDATE_SCRIPT="${SCRIPT_DIR}/../scripts/utilities/validate_desktop.sh"

if [ -f "${VALIDATE_SCRIPT}" ]; then
    bash "${VALIDATE_SCRIPT}" "$@"
elif [ -f "${HOME}/.config/scripts/utilities/validate_desktop.sh" ]; then
    bash "${HOME}/.config/scripts/utilities/validate_desktop.sh" "$@"
else
    echo "Error: validate_desktop.sh script not found." >&2
    exit 1
fi
