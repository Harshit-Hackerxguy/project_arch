#!/usr/bin/env bash
# =============================================================================
# Script Name: emoji.sh
# Description: Rofi-based emoji picker using rofimoji or custom list.
# Layer: Layer 9 — Automation & Productivity
# =============================================================================

set -euo pipefail

ROFI_THEME="${HOME}/.config/rofi/themes/cyber-minimal.rasi"

if command -v rofimoji >/dev/null 2>&1; then
    exec rofimoji --action copy --selector-args="-theme ${ROFI_THEME} -p '󰞅  Emoji'"
else
    # Fallback minimal emoji list if rofimoji is not installed
    emoji_list="😀 Grinning Face\n😂 Laughing\n😍 Heart Eyes\n🤔 Thinking\n👍 Thumbs Up\n🔥 Fire\n✨ Sparkles\n❤️ Red Heart\n🚀 Rocket\n✔ Checkmark\n⚡ High Voltage\n💻 Personal Computer\n🐧 Linux\n Arch Linux"
    chosen=$(printf "%b" "${emoji_list}" | rofi -dmenu -i -p "󰞅  Emoji" -theme "${ROFI_THEME}")
    
    if [[ -n "${chosen}" ]]; then
        emoji=$(echo "${chosen}" | awk '{print $1}')
        printf "%s" "${emoji}" | wl-copy
        notify-send -u low -a "Emoji Picker" "󰞅  Emoji Copied" "${emoji} copied to clipboard."
    fi
fi
