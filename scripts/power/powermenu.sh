#!/usr/bin/env bash
# =============================================================================
# Script Name: powermenu.sh
# Description: Cyber-Minimal Power Menu using Rofi with hibernate support.
# Layer: Layer 8 — Session, Lock Screen & Power Management
# =============================================================================

set -euo pipefail

ROFI_THEME="${HOME}/.config/rofi/themes/cyber-minimal.rasi"

readonly OPT_LOCK="  Lock Session"
readonly OPT_LOGOUT="󰍃  Log Out"
readonly OPT_SUSPEND="󰒲  Suspend"
readonly OPT_HIBERNATE="󰋊  Hibernate"
readonly OPT_REBOOT="󰜉  Reboot"
readonly OPT_SHUTDOWN="  Shut Down"

# Check if hibernate is supported by systemd
hibernate_supported=false
if grep -q "disk" /sys/power/state 2>/dev/null; then
    hibernate_supported=true
fi

if [ "${hibernate_supported}" = true ]; then
    menu_options="$(printf "%s\n%s\n%s\n%s\n%s\n%s" "${OPT_LOCK}" "${OPT_LOGOUT}" "${OPT_SUSPEND}" "${OPT_HIBERNATE}" "${OPT_REBOOT}" "${OPT_SHUTDOWN}")"
else
    menu_options="$(printf "%s\n%s\n%s\n%s\n%s" "${OPT_LOCK}" "${OPT_LOGOUT}" "${OPT_SUSPEND}" "${OPT_REBOOT}" "${OPT_SHUTDOWN}")"
fi

chosen=$(echo "${menu_options}" | rofi -dmenu -i -p "  Power" -theme "${ROFI_THEME}")

case "${chosen}" in
    "${OPT_LOCK}")
        if [ -x "${HOME}/.config/scripts/power/lock.sh" ]; then
            "${HOME}/.config/scripts/power/lock.sh"
        elif command -v hyprlock >/dev/null 2>&1; then
            hyprlock
        fi
        ;;
    "${OPT_LOGOUT}")
        if [ -x "${HOME}/.config/scripts/power/logout.sh" ]; then
            "${HOME}/.config/scripts/power/logout.sh"
        elif command -v hyprctl >/dev/null 2>&1; then
            hyprctl dispatch exit
        else
            loginctl terminate-user "$(whoami)"
        fi
        ;;
    "${OPT_SUSPEND}")
        if [ -x "${HOME}/.config/scripts/power/suspend.sh" ]; then
            "${HOME}/.config/scripts/power/suspend.sh"
        else
            systemctl suspend
        fi
        ;;
    "${OPT_HIBERNATE}")
        if [ -x "${HOME}/.config/scripts/power/suspend.sh" ]; then
            "${HOME}/.config/scripts/power/suspend.sh" &
        fi
        systemctl hibernate
        ;;
    "${OPT_REBOOT}")
        if [ -x "${HOME}/.config/scripts/power/reboot.sh" ]; then
            "${HOME}/.config/scripts/power/reboot.sh"
        else
            systemctl reboot
        fi
        ;;
    "${OPT_SHUTDOWN}")
        if [ -x "${HOME}/.config/scripts/power/shutdown.sh" ]; then
            "${HOME}/.config/scripts/power/shutdown.sh"
        else
            systemctl poweroff
        fi
        ;;
    *)
        exit 0
        ;;
esac
