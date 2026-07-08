#!/usr/bin/env bash
# =============================================================================
# Script Name: validate_desktop.sh
# Description: Validates desktop configuration, services, and dependencies.
# Layer: Final Validation
# =============================================================================

set -euo pipefail

COLOR_GREEN="\033[1;32m"
COLOR_RED="\033[1;31m"
COLOR_YELLOW="\033[1;33m"
COLOR_CYAN="\033[1;36m"
COLOR_RESET="\033[0m"

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

pass() {
    PASS_COUNT=$(( PASS_COUNT + 1 ))
    echo -e "  [${COLOR_GREEN}PASS${COLOR_RESET}] $1"
}

fail() {
    FAIL_COUNT=$(( FAIL_COUNT + 1 ))
    echo -e "  [${COLOR_RED}FAIL${COLOR_RESET}] $1" >&2
}

warn() {
    WARN_COUNT=$(( WARN_COUNT + 1 ))
    echo -e "  [${COLOR_YELLOW}WARN${COLOR_RESET}] $1"
}

echo -e "\n${COLOR_CYAN}=== project_arch Desktop Validation Suite ===${COLOR_RESET}\n"

# 1. Validate Core Binaries & Dependencies
echo "1. Checking Core Dependencies..."
for cmd in hyprland hyprlock hypridle waybar rofi dunst cliphist wl-paste swww-daemon notify-send brightnessctl pamixer playerctl; do
    if command -v "${cmd}" >/dev/null 2>&1; then
        pass "Binary found: ${cmd} ($(command -v "${cmd}"))"
    else
        fail "Missing required binary: ${cmd}"
    fi
done

# 2. Validate Configuration File Existence & Syntax
echo -e "\n2. Checking Configuration Files..."
for conf in \
    "${HOME}/.config/hypr/hyprlock.conf" \
    "${HOME}/.config/hypr/hypridle.conf" \
    "${HOME}/.config/waybar/config.jsonc" \
    "${HOME}/.config/waybar/style.css" \
    "${HOME}/.config/rofi/themes/cyber-minimal.rasi" \
    "${HOME}/.config/dunst/dunstrc" \
    "${HOME}/.config/gtk-3.0/settings.ini" \
    "${HOME}/.config/gtk-4.0/settings.ini"; do
    if [ -f "${conf}" ]; then
        pass "Config present: ${conf}"
    else
        fail "Config missing: ${conf}"
    fi
done

# Validate JSON/JSONC syntax for Waybar config
if command -v jq >/dev/null 2>&1 && [ -f "${HOME}/.config/waybar/config.jsonc" ]; then
    if sed 's/^\s*\/\/.*$//g; s/^\s*\/\*.*\*\/\s*$//g' "${HOME}/.config/waybar/config.jsonc" | jq . >/dev/null 2>&1; then
        pass "Waybar JSONC syntax is valid."
    else
        fail "Waybar JSONC syntax error detected in config.jsonc"
    fi
fi

# 3. Validate Running Services & Daemons (if in active Wayland session)
echo -e "\n3. Checking Runtime Services..."
if [ -n "${WAYLAND_DISPLAY:-}" ]; then
    pass "Active Wayland display detected: ${WAYLAND_DISPLAY}"
    
    for daemon in waybar dunst cliphist; do
        if pgrep -x "${daemon}" >/dev/null || pgrep -f "${daemon}" >/dev/null; then
            pass "Daemon running: ${daemon}"
        else
            warn "Daemon not active: ${daemon} (run autostart.sh to launch)"
        fi
    done
else
    warn "Not inside an active Wayland session (WAYLAND_DISPLAY unset); skipping runtime daemon checks."
fi

# 4. Check Script Permissions
echo -e "\n4. Checking Script Permissions..."
if [ -d "${HOME}/.config/scripts" ]; then
    while IFS= read -r -d '' script; do
        if [ -x "${script}" ]; then
            pass "Executable: ${script/#$HOME/\~}"
        else
            fail "Not executable: ${script/#$HOME/\~} (run: chmod +x '${script}')"
        fi
    done < <(find "${HOME}/.config/scripts" -type f -name "*.sh" -print0)
fi

# Summary Report
echo -e "\n${COLOR_CYAN}=== Validation Report ===${COLOR_RESET}"
echo -e "  Passed: ${COLOR_GREEN}${PASS_COUNT}${COLOR_RESET}"
echo -e "  Warnings: ${COLOR_YELLOW}${WARN_COUNT}${COLOR_RESET}"
echo -e "  Failed: ${COLOR_RED}${FAIL_COUNT}${COLOR_RESET}\n"

if (( FAIL_COUNT > 0 )); then
    echo -e "${COLOR_RED}Validation completed with errors. Please resolve the failing checks above.${COLOR_RESET}"
    exit 1
else
    echo -e "${COLOR_GREEN}All critical validation checks passed successfully!${COLOR_RESET}"
    exit 0
fi
