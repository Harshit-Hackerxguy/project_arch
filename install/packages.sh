#!/usr/bin/env bash
# =============================================================================
# Script Name: packages.sh
# Description: Installs all essential packages for a base Arch Linux system
#              before any desktop environment is configured. Packages are
#              grouped by function with comments explaining why each group
#              or package is needed.
#
# Usage:       sudo bash install/packages.sh
#              (or called from install.sh — preferred)
#
# Environment: Reads shared variables from variables.sh (auto-sourced).
#
# Author:      project_arch contributors
# Layer:       Layer 1 — Base System
# =============================================================================

set -euo pipefail
# -e: exit immediately on error
# -u: treat unset variables as errors
# -o pipefail: fail if any command in a pipeline fails

# Source shared variables and logging functions.
# ${BASH_SOURCE[0]} gives the path of this script regardless of how it is called.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/variables.sh"

# =============================================================================
# Package Lists
# =============================================================================
# Each array represents a logical group of packages.
# Every package is listed on its own line with a comment explaining its purpose.
# This makes it easy to audit, modify, or temporarily remove packages.

# -----------------------------------------------------------------------------
# System Essentials
# Packages that should be present on any Arch Linux system. Many of these
# may already be installed as part of the base install, but listing them here
# ensures they are present and documents why we depend on them.
# -----------------------------------------------------------------------------
readonly PACKAGES_SYSTEM=(
    "base-devel"      # Metapackage: gcc, make, binutils, etc. Required for
                      # building any software from source (including AUR).
    "linux-headers"   # Kernel headers matching the running kernel. Required
                      # for building kernel modules (e.g., GPU drivers, VirtualBox).
    "sudo"            # Allows a permitted user to run commands as root.
                      # Essential for secure privilege escalation.
    "polkit"          # Framework for non-privileged processes to communicate
                      # with privileged ones. Required by many desktop applications.
)

# -----------------------------------------------------------------------------
# Version Control
# Git is the foundation of the entire project workflow.
# -----------------------------------------------------------------------------
readonly PACKAGES_VCS=(
    "git"             # Distributed version control system. Required to clone
                      # this repository and manage all future changes.
    "git-delta"       # Syntax-highlighted git diff output. Makes reviewing
                      # changes significantly more readable.
)

# -----------------------------------------------------------------------------
# Build Utilities
# Tools required to compile software from source. Many of the packages
# installed in later layers will be built from the AUR.
# -----------------------------------------------------------------------------
readonly PACKAGES_BUILD=(
    "cmake"           # Cross-platform build system generator. Required for
                      # many C/C++ projects including some Hyprland dependencies.
    "meson"           # Fast build system used by Wayland and related projects.
    "ninja"           # Low-level build system typically used alongside Meson.
    "pkgconf"         # Package configuration tool. Helps compilers find
                      # installed library headers and link flags.
    "autoconf"        # Generates configure scripts for Makefile-based projects.
    "automake"        # Generates Makefile.in files for use with autoconf.
    "libtool"         # Generic library support script used by many build systems.
    "patch"           # Apply diff files to source code. Used by makepkg
                      # when AUR packages include source patches.
    "gdb"             # GNU Debugger. Useful when debugging native application
                      # crashes or build failures.
)

# -----------------------------------------------------------------------------
# Networking Utilities
# Tools for network management, downloading files, and network diagnostics.
# -----------------------------------------------------------------------------
readonly PACKAGES_NETWORK=(
    "networkmanager"  # Full-featured network connection manager. Handles
                      # Ethernet, WiFi, VPN, and mobile broadband.
                      # Controlled via nmcli or a graphical frontend.
    "network-manager-applet"  # System tray applet for NetworkManager.
                      # Used in Layer 3 with Waybar.
    "wireless_tools"  # Legacy wireless tools (iwconfig, iwlist). Useful for
                      # low-level WiFi diagnostics.
    "iwd"             # Intel Wireless Daemon. Can be used as a backend for
                      # NetworkManager or standalone. Included for diagnostics.
    "curl"            # Command-line HTTP/FTP client. Used extensively in
                      # scripts for downloading files and testing APIs.
    "wget"            # Alternative download tool. Some scripts and package
                      # sources require wget specifically.
    "rsync"           # Fast, incremental file transfer. Essential for backups,
                      # dotfile syncing, and efficient file copying.
    "nmap"            # Network exploration and security scanning tool.
                      # Useful for diagnosing connectivity issues.
    "bind"            # Provides `dig` for DNS diagnostics.
    "traceroute"      # Network path diagnostic tool.
    "whois"           # Query WHOIS records for domains and IP addresses.
)

# -----------------------------------------------------------------------------
# File and Archive Utilities
# Tools for compressing, extracting, and managing files.
# -----------------------------------------------------------------------------
readonly PACKAGES_ARCHIVE=(
    "tar"             # Standard tape archive utility. Handles .tar, .tar.gz,
                      # .tar.xz, and other common archive formats.
    "gzip"            # GNU zip compression. Part of most .tar.gz workflows.
    "bzip2"           # bzip2 compression. Used by some source packages.
    "xz"              # LZMA compression (high ratio). Used by Arch packages
                      # (.pkg.tar.xz) and many source archives.
    "zstd"            # Zstandard compression. Used by modern Arch packages
                      # (.pkg.tar.zst) and increasingly by other software.
    "unzip"           # Extract .zip archives. Many downloads use .zip format.
    "zip"             # Create .zip archives. Required by some build systems.
    "p7zip"           # Provides 7z — handles a wide range of archive formats
                      # including .7z, .rar (extraction), .cab, .iso.
    "lz4"             # Fast LZ4 compression. Used by some initramfs builds.
)

# -----------------------------------------------------------------------------
# Terminal and Shell Utilities
# Core command-line tools that improve the shell experience and are referenced
# in scripts across all layers.
# -----------------------------------------------------------------------------
readonly PACKAGES_TERMINAL=(
    "neovim"          # Primary text editor. Configured in Layer 4 but
                      # installed here so it is available immediately for
                      # editing config files during setup.
    "tmux"            # Terminal multiplexer. Enables persistent sessions,
                      # multiple panes, and detachable sessions.
    "bash-completion" # Programmable tab-completion for Bash commands.
                      # Significantly improves shell usability.
    "ripgrep"         # Fast recursive text search (rg). Replaces grep for
                      # searching source code. Used in scripts and Neovim.
    "fd"              # User-friendly alternative to find. Faster and uses
                      # gitignore rules by default. Used in scripts and Neovim.
    "fzf"             # Fuzzy finder for the terminal. Enables fuzzy search
                      # through command history, files, and custom lists.
    "bat"             # cat with syntax highlighting and git integration.
                      # Configured as the default pager for many tools.
    "eza"             # Modern replacement for ls. Color output, git status,
                      # tree view. Aliased to ls in shell configuration.
    "zoxide"          # Smarter cd command. Learns frequently visited
                      # directories and allows fuzzy jumping.
    "yq"              # Command-line YAML/JSON/XML processor. Useful for
                      # parsing configuration files in scripts.
    "jq"              # Command-line JSON processor. Used in scripts that
                      # interact with APIs or JSON configuration files.
    "tree"            # Display directory structures as a tree. Useful for
                      # documentation and understanding project layouts.
    "htop"            # Interactive process viewer. More readable than top.
    "btop"            # Resource monitor with a modern TUI interface.
    "dust"            # du alternative — shows disk usage as a tree.
    "duf"             # df alternative — shows disk usage with better formatting.
    "procs"           # ps alternative — modern process viewer.
)

# -----------------------------------------------------------------------------
# System Administration Tools
# Tools for managing the system at a lower level.
# -----------------------------------------------------------------------------
readonly PACKAGES_SYSADMIN=(
    "man-db"          # Manual page database. Provides the `man` command for
                      # reading documentation. Essential on any system.
    "man-pages"       # Linux man pages. The documentation for system calls,
                      # library functions, and command-line tools.
    "texinfo"         # GNU documentation system. Some tools use info pages
                      # instead of man pages.
    "lsof"            # List open files. Diagnoses which processes hold file
                      # handles, useful for debugging permission errors.
    "strace"          # System call tracer. Essential for debugging cryptic
                      # application failures.
    "ltrace"          # Library call tracer. Complementary to strace.
    "which"           # Locate commands in PATH. Useful in scripts and shell.
    "lshw"            # Detailed hardware information. Identifies all hardware
                      # components on the system.
    "pciutils"        # Provides lspci for listing PCI devices (GPU, NIC, etc.)
    "usbutils"        # Provides lsusb for listing USB devices.
    "dmidecode"       # Reads hardware information from BIOS/UEFI.
    "smartmontools"   # Monitor drive health via S.M.A.R.T. data.
    "e2fsprogs"       # Ext2/3/4 filesystem tools. fsck, mkfs.ext4, etc.
    "dosfstools"      # FAT filesystem tools. Required for EFI partition management.
    "ntfs-3g"         # NTFS read/write support. Needed for accessing Windows
                      # partitions if dual-booting.
    "reflector"       # Retrieves and sorts Arch Linux mirrorlist. Ensures
                      # pacman uses the fastest available mirrors.
)

# -----------------------------------------------------------------------------
# Security Tools
# -----------------------------------------------------------------------------
readonly PACKAGES_SECURITY=(
    "gnupg"           # GNU Privacy Guard. Used for signing git commits,
                      # verifying package signatures, and encrypting files.
    "openssh"         # SSH client and server. Required for remote access
                      # and key-based authentication to remote services.
    "pass"            # Standard Unix password manager. Password store backed
                      # by GPG encryption and git for version control.
    "openssl"         # Cryptography toolkit. Many tools depend on this
                      # library; it is also useful for generating certificates.
)

# -----------------------------------------------------------------------------
# Python Development Environment
# Python is needed for various system scripts, tools, and utilities.
# This is not a full Python development setup — that belongs in Layer 4.
# -----------------------------------------------------------------------------
readonly PACKAGES_PYTHON=(
    "python"          # Python 3 interpreter. Required by many system tools
                      # (including some AUR build scripts).
    "python-pip"      # Python package installer. Required to install Python
                      # tools not available in the official repositories.
    "python-setuptools" # Python packaging tools. Required as a build
                      # dependency for many Python packages.
)

# -----------------------------------------------------------------------------
# Fonts (Base Set)
# These fonts are installed in Layer 1 because they are required before
# the desktop environment is configured. Without fonts, some tooling and
# terminal configurations will not render correctly.
# Full font installation and configuration happens in Layer 5.
# -----------------------------------------------------------------------------
readonly PACKAGES_FONTS=(
    "ttf-jetbrains-mono-nerd"   # JetBrains Mono with Nerd Font icons. Primary
                                # monospace font for the terminal. Nerd Fonts
                                # provide the icon glyphs used in shell prompts,
                                # status bars, and terminal file managers.
    "ttf-nerd-fonts-symbols"    # Nerd Font symbol-only font. Used as a
                                # fallback for icon rendering in tools.
    "noto-fonts"                # Google Noto fonts — covers a very wide range
                                # of Unicode characters and scripts. Prevents
                                # "tofu" (□) for characters not in other fonts.
    "noto-fonts-emoji"          # Color emoji font. Required for emoji rendering
                                # in applications and the terminal.
    "ttf-liberation"            # Metric-compatible replacements for common
                                # Microsoft fonts. Prevents layout issues in
                                # documents designed with MS fonts.
)

# =============================================================================
# Installation Functions
# =============================================================================

# install_package_group — installs all packages in the given array.
# Skips packages that are already installed (pacman --needed).
# Arguments:
#   $1 — human-readable group name for log output
#   $@ — remaining arguments are package names
install_package_group() {
    local group_name="${1:?install_package_group: group name required}"
    shift
    local packages=("$@")

    log_info "Installing ${group_name}..."

    # Pass the full list to pacman at once rather than one at a time.
    # This is more efficient and allows pacman to resolve dependencies
    # across the whole group simultaneously.
    if ! sudo pacman -S ${PACMAN_FLAGS} "${packages[@]}"; then
        log_error "Failed to install one or more packages in group: ${group_name}"
        log_error "Packages attempted: ${packages[*]}"
        return 1
    fi

    log_ok "${group_name} installed."
}

# sync_package_database — refreshes the pacman package database.
# This must be done before installing packages to ensure we have the
# latest package versions. Running pacman -S without syncing first
# can result in installing outdated packages or failing to find new ones.
sync_package_database() {
    log_info "Synchronizing package database..."
    sudo pacman -Sy || {
        log_error "Failed to synchronize package database."
        log_error "Check your internet connection and try again."
        return 1
    }
    log_ok "Package database synchronized."
}

# update_system — performs a full system upgrade before installing new packages.
# Installing packages onto an out-of-date system (partial upgrade) can cause
# library version mismatches and broken dependencies. Always update first.
update_system() {
    log_info "Performing full system upgrade (pacman -Syu)..."
    log_warn "This may take several minutes on an outdated system."
    sudo pacman -Syu ${PACMAN_FLAGS} || {
        log_error "System upgrade failed."
        return 1
    }
    log_ok "System is up to date."
}

# install_aur_helper — installs the paru AUR helper if not already present.
# paru is written in Rust and is a feature-complete, maintained fork of yay.
# It wraps pacman and adds AUR support with minimal overhead.
# AUR packages are required in later layers (Hyprland, some fonts, etc.)
install_aur_helper() {
    if command_exists paru; then
        log_ok "paru is already installed — skipping."
        return 0
    fi

    log_info "Installing paru AUR helper..."

    # AUR packages must be built as a non-root user.
    # We clone the paru PKGBUILD to a temporary directory and build it.
    local build_dir
    build_dir="$(mktemp -d)"

    # Ensure the temp directory is cleaned up on exit, even if the script fails.
    # shellcheck disable=SC2064
    trap "rm -rf '${build_dir}'" EXIT

    git clone https://aur.archlinux.org/paru.git "${build_dir}/paru" || {
        log_error "Failed to clone paru repository."
        return 1
    }

    (
        # Run in a subshell to avoid changing the script's working directory.
        cd "${build_dir}/paru"
        makepkg -si --noconfirm
    ) || {
        log_error "Failed to build and install paru."
        return 1
    }

    log_ok "paru installed."
}

# =============================================================================
# Main
# =============================================================================

main() {
    require_not_root

    log_section "Layer 1 — Package Installation"

    sync_package_database
    update_system

    install_package_group "System Essentials"   "${PACKAGES_SYSTEM[@]}"
    install_package_group "Version Control"     "${PACKAGES_VCS[@]}"
    install_package_group "Build Utilities"     "${PACKAGES_BUILD[@]}"
    install_package_group "Networking"          "${PACKAGES_NETWORK[@]}"
    install_package_group "Archive Tools"       "${PACKAGES_ARCHIVE[@]}"
    install_package_group "Terminal Utilities"  "${PACKAGES_TERMINAL[@]}"
    install_package_group "System Admin Tools"  "${PACKAGES_SYSADMIN[@]}"
    install_package_group "Security Tools"      "${PACKAGES_SECURITY[@]}"
    install_package_group "Python"              "${PACKAGES_PYTHON[@]}"
    install_package_group "Base Fonts"          "${PACKAGES_FONTS[@]}"

    install_aur_helper

    log_section "Package Installation Complete"
    log_ok "All Layer 1 packages are installed."
    log_info "Next step: bash install/services.sh"
}

main "$@"
