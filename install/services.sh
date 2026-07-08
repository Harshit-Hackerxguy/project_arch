#!/usr/bin/env bash
# =============================================================================
# Script Name: services.sh
# Description: Enables and starts essential system services via systemd.
#              Each service is documented with the reason it is needed and
#              the expected behavior after enabling it.
#
#              Services are enabled (start on boot) and, where appropriate,
#              also started immediately so the system is functional without
#              a reboot.
#
# Usage:       sudo bash install/services.sh
#              (or called from install.sh — preferred)
#
# Environment: Reads shared variables from variables.sh (auto-sourced).
# Requires:    packages.sh must have been run first (services need packages).
#
# Author:      project_arch contributors
# Layer:       Layer 1 — Base System
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/variables.sh"

# =============================================================================
# Service Definitions
# =============================================================================
# Each service entry is a string with the format:
#   "service_name|description"
#
# The description explains:
#   - what the service does
#   - why it is needed in this environment
#   - any important notes about its behavior

declare -a SYSTEM_SERVICES=(
    # -------------------------------------------------------------------------
    # NetworkManager
    # Manages network connections for Ethernet, WiFi, and mobile broadband.
    # This is the primary network management daemon for this desktop environment.
    # It provides the D-Bus API used by nm-applet (Layer 3) and nmcli.
    #
    # NOTE: If dhcpcd is running, it may conflict with NetworkManager.
    #       services.sh handles this by disabling dhcpcd if present.
    # -------------------------------------------------------------------------
    "NetworkManager|Network connection management (Ethernet, WiFi, VPN)"

    # -------------------------------------------------------------------------
    # bluetooth
    # Manages Bluetooth hardware and connections.
    # Required in Layer 3 for Bluetooth device management from the status bar.
    # Even if no Bluetooth hardware is present, enabling this service is
    # harmless — it will simply do nothing.
    # -------------------------------------------------------------------------
    "bluetooth|Bluetooth hardware management"

    # -------------------------------------------------------------------------
    # fstrim.timer
    # Runs fstrim (TRIM/discard) weekly on all mounted filesystems that
    # support it. TRIM is essential for SSD longevity and performance.
    # This is a systemd timer, not a service — it creates a scheduled job.
    #
    # NOTE: This is safe to enable even on HDDs or VMs — fstrim will simply
    #       report nothing to trim and exit cleanly.
    # -------------------------------------------------------------------------
    "fstrim.timer|Periodic SSD TRIM for drive health and performance"

    # -------------------------------------------------------------------------
    # reflector.timer
    # Runs reflector periodically to update /etc/pacman.d/mirrorlist with
    # the fastest and most recently synchronized Arch mirrors.
    # A fresh, local mirrorlist significantly speeds up package downloads.
    #
    # NOTE: The reflector service can be configured via /etc/xdg/reflector/reflector.conf.
    #       We configure this after enabling the service.
    # -------------------------------------------------------------------------
    "reflector.timer|Automatic pacman mirror list updates"

    # -------------------------------------------------------------------------
    # systemd-timesyncd
    # NTP time synchronization daemon built into systemd.
    # Keeps the system clock accurate without needing a separate NTP daemon.
    # Required for correct TLS certificate validation and git commit timestamps.
    # -------------------------------------------------------------------------
    "systemd-timesyncd|Network time synchronization (NTP)"
)

# =============================================================================
# Services to Disable
# =============================================================================
# Some services conflict with our chosen tools and must be disabled if present.

declare -a CONFLICTING_SERVICES=(
    # dhcpcd conflicts with NetworkManager — both try to manage network interfaces.
    # NetworkManager is our chosen network manager, so dhcpcd must be stopped.
    "dhcpcd"
)

# =============================================================================
# Service Management Functions
# =============================================================================

# enable_and_start_service — enables a service to start at boot and
# starts it immediately if it is not already running.
# Arguments:
#   $1 — service name (with or without .service/.timer suffix)
#   $2 — human-readable description for log output
enable_and_start_service() {
    local service_name="${1:?enable_and_start_service: service name required}"
    local description="${2:-${service_name}}"

    log_info "Enabling: ${description} (${service_name})"

    # Enable the service (marks it to start at boot via symlink)
    if ! sudo systemctl enable "${service_name}" 2>/dev/null; then
        log_warn "Could not enable ${service_name} — it may not be installed."
        log_warn "Skipping ${service_name}."
        return 0
    fi

    # Start the service now (so we do not need a reboot to use it)
    # Timers use 'start' just like services — they begin their schedule immediately.
    if ! sudo systemctl start "${service_name}" 2>/dev/null; then
        log_warn "Service ${service_name} enabled but could not be started now."
        log_warn "It will start at next boot."
        return 0
    fi

    log_ok "${description} enabled and started."
}

# disable_conflicting_service — stops and disables a service that conflicts
# with one of our chosen tools. Only acts if the service is actually present.
# Arguments:
#   $1 — service name
disable_conflicting_service() {
    local service_name="${1:?disable_conflicting_service: service name required}"

    # Check if the service unit exists at all — if not, nothing to do.
    if ! systemctl list-unit-files "${service_name}.service" &>/dev/null \
       && ! systemctl list-unit-files "${service_name}" &>/dev/null; then
        log_info "${service_name} not present — no conflict to resolve."
        return 0
    fi

    # Only stop and disable if it is currently enabled or running.
    if service_enabled "${service_name}" || service_active "${service_name}"; then
        log_warn "Disabling conflicting service: ${service_name}"
        sudo systemctl stop "${service_name}" 2>/dev/null || true
        sudo systemctl disable "${service_name}" 2>/dev/null || true
        log_ok "${service_name} disabled."
    else
        log_info "${service_name} is already inactive — no action needed."
    fi
}

# configure_reflector — writes a basic reflector configuration file.
# This sets reflector to select the 10 fastest HTTPS mirrors, sorted by
# download rate, from the last 24 hours.
#
# The file at /etc/xdg/reflector/reflector.conf is read by reflector.service
# when it runs. Without this config, reflector uses its defaults which may
# not produce optimal mirror selection.
configure_reflector() {
    local reflector_conf="/etc/xdg/reflector/reflector.conf"

    log_info "Writing reflector configuration to ${reflector_conf}..."

    # Only write the config if the reflector package is installed.
    if ! command_exists reflector; then
        log_warn "reflector is not installed — skipping configuration."
        return 0
    fi

    sudo mkdir -p "$(dirname "${reflector_conf}")"

    # Write configuration using a heredoc.
    # Each option is documented in the reflector man page.
    sudo tee "${reflector_conf}" > /dev/null <<'EOF'
# /etc/xdg/reflector/reflector.conf
# Configuration for the reflector mirror selection service.
# See: man reflector

# Only use HTTPS mirrors for security.
--protocol https

# Select mirrors that were synchronized within the last 24 hours.
# This avoids using mirrors that are out of date.
--latest 20

# From those, select the 10 fastest by download rate.
--number 10
--sort rate

# Save the generated mirrorlist to the pacman mirror file.
--save /etc/pacman.d/mirrorlist
EOF

    log_ok "reflector configured."
}

# configure_bluetooth — enables experimental features in the Bluetooth daemon.
# This is needed for some Bluetooth audio profiles (A2DP, aptX) to work
# correctly in a PipeWire audio environment (configured in Layer 2+).
configure_bluetooth() {
    local bluetooth_conf="/etc/bluetooth/main.conf"

    if [[ ! -f "${bluetooth_conf}" ]]; then
        log_warn "${bluetooth_conf} does not exist — bluetooth may not be installed."
        return 0
    fi

    log_info "Checking Bluetooth experimental features..."

    # Only add the setting if it is not already present.
    if ! grep -q "^Experimental = true" "${bluetooth_conf}"; then
        log_info "Enabling Bluetooth experimental features (for audio profiles)..."
        # Append to the [Policy] section or the end of the file.
        # This is a safe append — main.conf is not overwritten.
        echo "" | sudo tee -a "${bluetooth_conf}" > /dev/null
        echo "# Enabled by project_arch for PipeWire audio profile support" \
            | sudo tee -a "${bluetooth_conf}" > /dev/null
        echo "Experimental = true" \
            | sudo tee -a "${bluetooth_conf}" > /dev/null
        log_ok "Bluetooth experimental features enabled."
    else
        log_ok "Bluetooth experimental features already enabled."
    fi
}

# =============================================================================
# Main
# =============================================================================

main() {
    require_not_root

    log_section "Layer 1 — Service Configuration"

    # Step 1: Disable conflicting services first to prevent conflicts
    # when we start our chosen services.
    log_info "Resolving service conflicts..."
    for service in "${CONFLICTING_SERVICES[@]}"; do
        disable_conflicting_service "${service}"
    done

    # Step 2: Apply service-specific configuration before enabling.
    configure_reflector
    configure_bluetooth

    # Step 3: Enable and start each service.
    log_info "Enabling system services..."
    for entry in "${SYSTEM_SERVICES[@]}"; do
        # Split the entry on '|' to get the service name and description.
        local service_name="${entry%%|*}"
        local description="${entry##*|}"
        enable_and_start_service "${service_name}" "${description}"
    done

    log_section "Service Configuration Complete"
    log_ok "All Layer 1 services have been enabled."
    log_info "Next step: bash install/directories.sh"
}

main "$@"
