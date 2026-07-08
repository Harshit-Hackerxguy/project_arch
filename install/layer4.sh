#!/usr/bin/env bash
# =============================================================================
# Script Name: layer4.sh
# Description: Layer 4 installer — Kitty, Zsh, Starship, Fastfetch.
#
#              Installs and configures:
#                - Kitty (GPU-accelerated terminal)
#                - Zsh (shell)
#                - Starship (cross-shell prompt)
#                - Fastfetch (system info display)
#
# Usage:       bash install/layer4.sh
# Requires:    Layer 3 must be installed first.
#
# Author:      project_arch contributors
# Layer:       Layer 4 — Terminal Environment
# =============================================================================

set -euo pipefail

CURRENT_LAYER="Layer 4"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

# =============================================================================
# Package Definitions
# =============================================================================

readonly LAYER4_PACKAGES=(
    "kitty"                       # GPU-accelerated terminal emulator
    "zsh"                         # Z Shell
    "zsh-completions"             # Additional Zsh completion definitions
    "zsh-autosuggestions"         # Fish-like autosuggestions for Zsh
    "zsh-syntax-highlighting"    # Syntax highlighting for Zsh commands
    "starship"                    # Cross-shell prompt
    "fastfetch"                   # Fast system information display
)

# =============================================================================
# Configuration Deployment
# =============================================================================

deploy_kitty_config() {
    log_info "Deploying Kitty configuration..."

    local dest="${XDG_CONFIG_HOME}/kitty"
    mkdir -p "${dest}"

    deploy_config "kitty/kitty.conf" "${dest}/kitty.conf"

    # Deploy kitty themes if they exist.
    if [[ -d "${REPO_ROOT}/kitty/themes" ]]; then
        deploy_config "kitty/themes" "${dest}/themes"
    fi

    log_ok "Kitty configuration deployed."
}

deploy_zsh_config() {
    log_info "Deploying Zsh configuration..."

    # .zshenv goes in HOME — it is read by all Zsh invocations.
    if [[ -f "${REPO_ROOT}/zsh/.zshenv" ]]; then
        deploy_config "zsh/.zshenv" "${HOME}/.zshenv"
    fi

    # .zshrc goes in HOME — interactive shell configuration.
    if [[ -f "${REPO_ROOT}/zsh/.zshrc" ]]; then
        deploy_config "zsh/.zshrc" "${HOME}/.zshrc"
    fi

    log_ok "Zsh configuration deployed."
}

deploy_starship_config() {
    log_info "Deploying Starship configuration..."

    local dest="${XDG_CONFIG_HOME}"
    mkdir -p "${dest}"

    deploy_config "starship/starship.toml" "${dest}/starship.toml"

    log_ok "Starship configuration deployed."
}

deploy_fastfetch_config() {
    log_info "Deploying Fastfetch configuration..."

    local dest="${XDG_CONFIG_HOME}/fastfetch"
    mkdir -p "${dest}"

    deploy_config "fastfetch/config.jsonc" "${dest}/config.jsonc"

    log_ok "Fastfetch configuration deployed."
}

# =============================================================================
# Set Default Shell
# =============================================================================

set_default_shell() {
    log_info "Checking default shell..."

    local zsh_path
    zsh_path="$(command -v zsh)"

    if [[ -z "${zsh_path}" ]]; then
        log_error "Zsh not found in PATH — cannot set as default shell."
        return 1
    fi

    # Check if zsh is already the default shell.
    local current_shell
    current_shell="$(getent passwd "$(whoami)" | cut -d: -f7)"

    if [[ "${current_shell}" == "${zsh_path}" ]]; then
        log_ok "Default shell is already Zsh."
        return 0
    fi

    # Ensure zsh is listed in /etc/shells.
    if ! grep -q "^${zsh_path}$" /etc/shells 2>/dev/null; then
        log_info "Adding ${zsh_path} to /etc/shells..."
        echo "${zsh_path}" | sudo tee -a /etc/shells > /dev/null
    fi

    log_info "Changing default shell to Zsh..."
    if chsh -s "${zsh_path}"; then
        log_ok "Default shell changed to Zsh. Log out and back in to activate."
    else
        log_warn "Could not change shell automatically."
        log_warn "Run manually: chsh -s ${zsh_path}"
    fi
}

# =============================================================================
# Main
# =============================================================================

main() {
    layer_banner "Layer 4 — Terminal" "Kitty, Zsh, Starship, Fastfetch"

    require_not_root
    require_layer 3

    # Install packages.
    log_section "Installing Layer 4 Packages"
    install_packages "Terminal Environment" "${LAYER4_PACKAGES[@]}"

    # Deploy configs.
    log_section "Deploying Layer 4 Configuration"
    deploy_kitty_config
    deploy_zsh_config
    deploy_starship_config
    deploy_fastfetch_config

    # Set Zsh as default.
    log_section "Shell Configuration"
    set_default_shell

    # Summary.
    log_section "Layer 4 Installation Complete"
    echo -e "  ${COLOR_GREEN}${COLOR_BOLD}Layer 4 is complete.${COLOR_RESET}"
    echo ""
    echo -e "  ${COLOR_CYAN}Next steps:${COLOR_RESET}"
    echo -e "  1. Run  ${COLOR_BOLD}bash install/verify_layer4.sh${COLOR_RESET}  to verify."
    echo -e "  2. Log out and back in to activate Zsh as your default shell."
    echo -e "  3. When ready, proceed to Layer 5: ${COLOR_BOLD}bash install/layer5.sh${COLOR_RESET}"
    echo ""
}

main "$@"
