#!/usr/bin/env bash
# =============================================================================
# Script Name: record.sh
# Description: Screen recording utility using wf-recorder with audio support.
# Layer: Layer 9 — Automation & Productivity
# =============================================================================

set -euo pipefail

SAVE_DIR="${HOME}/Videos/Recordings"
mkdir -p "${SAVE_DIR}"

PID_FILE="/tmp/wf-recorder.pid"

if [ -f "${PID_FILE}" ] && kill -0 "$(cat "${PID_FILE}")" 2>/dev/null; then
    kill -SIGINT "$(cat "${PID_FILE}")"
    rm -f "${PID_FILE}"
    notify-send -u normal -a "Recording" -i "media-record" "󰑊  Recording Saved" "Screen recording stopped and saved to ${SAVE_DIR}."
    exit 0
fi

TIMESTAMP="$(date '+%Y%m%d_%H%M%S')"
FILENAME="${SAVE_DIR}/recording_${TIMESTAMP}.mp4"

case "${1:-screen}" in
    "screen"|"full")
        notify-send -u low -a "Recording" -i "media-record" "󰑊  Recording Started" "Recording full screen..."
        wf-recorder -f "${FILENAME}" &
        echo $! > "${PID_FILE}"
        ;;
    "area"|"region")
        geom="$(slurp -d -c 38BDF8 -w 2)"
        notify-send -u low -a "Recording" -i "media-record" "󰑊  Recording Started" "Recording selected region..."
        wf-recorder -g "${geom}" -f "${FILENAME}" &
        echo $! > "${PID_FILE}"
        ;;
    "audio")
        audio_dev=$(pulse-cmd list-sources 2>/dev/null | grep 'name:' | awk '{print $2}' | grep 'monitor' | head -n 1 || echo "default")
        notify-send -u low -a "Recording" -i "media-record" "󰑊  Recording Started" "Recording screen with audio..."
        wf-recorder --audio="${audio_dev}" -f "${FILENAME}" &
        echo $! > "${PID_FILE}"
        ;;
    "stop")
        if [ -f "${PID_FILE}" ]; then
            kill -SIGINT "$(cat "${PID_FILE}")" 2>/dev/null || true
            rm -f "${PID_FILE}"
            notify-send -u normal -a "Recording" -i "media-record" "󰑊  Recording Stopped" "Saved to ${SAVE_DIR}."
        fi
        ;;
    *)
        echo "Usage: $0 [screen|area|audio|stop]" >&2
        exit 1
        ;;
esac
