#!/usr/bin/env bash

if command -v nvidia-smi &>/dev/null; then
    nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | head -1 | tr -d ' '
elif [[ -f /sys/class/drm/card0/device/gpu_busy_percent ]]; then
    cat /sys/class/drm/card0/device/gpu_busy_percent
elif command -v radeontop &>/dev/null; then
    radeontop -d - -l 1 2>/dev/null | awk -F'[, ]+' '/gpu/ {gsub(/%/,"",$2); print $2; exit}'
else
    echo "0"
fi
