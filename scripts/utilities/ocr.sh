#!/usr/bin/env bash
# =============================================================================
# Script Name: ocr.sh
# Description: Optical character recognition from screen region to clipboard.
# Layer: Layer 9 — Automation & Productivity
# =============================================================================

set -euo pipefail

if ! command -v tesseract >/dev/null 2>&1 || ! command -v grim >/dev/null 2>&1 || ! command -v slurp >/dev/null 2>&1; then
    notify-send -u critical -a "OCR Helper" "Error" "Required tools (grim, slurp, tesseract) not installed." >&2
    exit 1
fi

TMP_IMG="$(mktemp /tmp/ocr_XXXXXX.png)"
TMP_TXT="${TMP_IMG%.*}"

trap 'rm -f "${TMP_IMG}" "${TMP_TXT}.txt"' EXIT

notify-send -u low -a "OCR Helper" "󰞟  Select Region" "Select an area on screen to extract text..."

if grim -g "$(slurp -d -c 38BDF8 -w 2)" "${TMP_IMG}"; then
    if tesseract "${TMP_IMG}" "${TMP_TXT}" -l eng --dpi 192 --psm 6 >/dev/null 2>&1; then
        text=$(cat "${TMP_TXT}.txt" | sed 's/^[ \t]*//;s/[ \t]*$//' | tr -d '\f')
        if [[ -n "${text}" ]]; then
            printf "%s" "${text}" | wl-copy
            notify-send -u normal -a "OCR Helper" "󰞟  Text Extracted" "${text}"
        else
            notify-send -u normal -a "OCR Helper" "󰞟  No Text Found" "Could not recognize any text in region."
        fi
    else
        notify-send -u critical -a "OCR Helper" "Error" "Tesseract OCR processing failed."
    fi
fi
