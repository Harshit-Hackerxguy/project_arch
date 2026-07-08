#!/usr/bin/env bash
# =============================================================================
# Script Name: verify_layer4.sh
# Description: Verification script for Layer 4 — Kitty, Zsh, Starship, Fastfetch.
#
# Usage:       bash install/verify_layer4.sh
# Exit codes:  0 — all checks passed, 1 — one or more failed
#
# Author:      project_arch contributors
# Layer:       Layer 4 — Terminal Environment
# =============================================================================

set -euo pipefail

CURRENT_LAYER="Layer 4"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

main() {
    log_section "Layer 4 — Terminal Environment Verification"

    set +e

    # -- Packages --
    log_info "Verifying packages..."
    v_check_package "kitty"
    v_check_package "zsh"
    v_check_package "zsh-completions"
    v_check_package "zsh-autosuggestions"
    v_check_package "zsh-syntax-highlighting"
    v_check_package "starship"
    v_check_package "fastfetch"

    # -- Commands --
    log_info "Verifying commands..."
    v_check_command "kitty"       "Kitty terminal"
    v_check_command "zsh"         "Zsh shell"
    v_check_command "starship"    "Starship prompt"
    v_check_command "fastfetch"   "Fastfetch"

    # -- Kitty Config --
    log_info "Verifying Kitty configuration..."
    v_check_dir  "${XDG_CONFIG_HOME}/kitty"
    v_check_file "${XDG_CONFIG_HOME}/kitty/kitty.conf"

    # -- Zsh Config --
    log_info "Verifying Zsh configuration..."
    v_check_file "${HOME}/.zshrc"

    if [[ -f "${HOME}/.zshenv" ]]; then
        v_pass ".zshenv present"
    else
        v_warn ".zshenv not found — optional but recommended"
    fi

    # -- Default Shell --
    log_info "Verifying default shell..."
    local current_shell
    current_shell="$(getent passwd "$(whoami)" | cut -d: -f7)"
    if [[ "${current_shell}" == *"zsh"* ]]; then
        v_pass "Default shell is Zsh (${current_shell})"
    else
        v_warn "Default shell is not Zsh (${current_shell}) — run: chsh -s \$(which zsh)"
    fi

    # -- Starship Config --
    log_info "Verifying Starship configuration..."
    v_check_file "${XDG_CONFIG_HOME}/starship.toml"

    # -- Fastfetch Config --
    log_info "Verifying Fastfetch configuration..."
    v_check_dir  "${XDG_CONFIG_HOME}/fastfetch"
    v_check_file "${XDG_CONFIG_HOME}/fastfetch/config.jsonc"

    set -e

    v_report "Layer 4"
}

main "$@"
