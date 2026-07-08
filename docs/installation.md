# Installation Guide

This document describes the complete installation procedure for `project_arch`,
from a blank Arch Linux base system to a fully configured desktop environment.

Each section corresponds to one installation layer. Complete layers in order.
Do not skip layers — each layer is a prerequisite for the next.

---

## Prerequisites

Before beginning, you need a working Arch Linux base installation. This guide
assumes you have completed one of the following:

- Manual Arch Linux installation following the [official installation guide](https://wiki.archlinux.org/title/Installation_guide)
- `archinstall` automated installation (minimal profile, no desktop environment)

**Your system must have:**
- A working internet connection
- A non-root user account with `sudo` privileges
- `git` installed (or install it now: `pacman -S git`)
- This repository cloned to your home directory

```bash
git clone https://github.com/your-username/project_arch.git ~/project_arch
cd ~/project_arch
```

---

## Step 0 — Read Before Running

> **This is not optional.**
>
> Read every script you intend to run before executing it. Shell scripts run
> with your user's (or root's) permissions. Understanding what a script does
> before you run it is basic operational hygiene.

Review the install scripts:

```bash
cat install/variables.sh
cat install/packages.sh
cat install/services.sh
cat install/directories.sh
cat install/shell.sh
cat install/verify.sh
cat install/install.sh
```

---

## Layer 1 — Base System Installation

Layer 1 prepares the operating system with all packages, services, and
configuration needed before a desktop environment can be installed.

### What Layer 1 Does

1. Installs essential system packages (see `install/packages.sh` for the full
   list with rationale)
2. Enables required system services
3. Creates standard XDG directories and project-specific directories
4. Configures the base shell environment
5. Exports necessary environment variables
6. Verifies the installation is complete

### Running Layer 1

```bash
cd ~/project_arch

# Option 1: Run the full installation (recommended)
bash install/install.sh

# Option 2: Run individual modules (for partial installs or debugging)
source install/variables.sh
bash install/packages.sh
bash install/services.sh
bash install/directories.sh
bash install/shell.sh
bash install/verify.sh
```

### Expected Duration

A Layer 1 installation with a fast internet connection takes approximately
5–15 minutes depending on the number of packages and download speed.

### Expected Output

The installer produces colored, prefixed output:

```
[INFO]  Starting project_arch Layer 1 installation...
[INFO]  Installing development tools...
[ OK ]  git installed.
[ OK ]  base-devel installed.
[INFO]  Enabling services...
[ OK ]  NetworkManager.service enabled.
...
[INFO]  Verification complete.
[ OK ]  All Layer 1 checks passed.
```

### After Layer 1

After a successful Layer 1 installation:

1. **Log out and log back in** — environment variables set in `~/.bash_profile`
   will not be active until you start a new session
2. Run the verification script to confirm everything is in order:
   ```bash
   bash install/verify.sh
   ```
3. Reboot is recommended (but not required) before proceeding to Layer 2

---

## Layer 2 — Compositor (Planned)

Layer 2 is not yet implemented. See [`roadmap.md`](roadmap.md) for the planned
scope and deliverables.

When Layer 2 is available, installation instructions will appear here.

**What Layer 2 will do:**
- Install Hyprland and related packages
- Configure monitors, keybindings, and workspaces
- Set up autostart for Layer 3 components

---

## Layer 3 — Desktop Shell (Planned)

Layer 3 is not yet implemented.

**What Layer 3 will do:**
- Configure Waybar, Rofi, and Dunst
- Set up screenshot and clipboard tools

---

## Layer 4 — Terminal Environment (Planned)

Layer 4 is not yet implemented.

**What Layer 4 will do:**
- Configure Kitty terminal
- Configure Zsh with plugins and prompt
- Set up developer tooling (git, ssh, gpg)

---

## Layer 5 — Visual Polish (Planned)

Layer 5 is not yet implemented.

**What Layer 5 will do:**
- Configure GTK theming, icons, and cursors
- Establish the shared color token system
- Set up wallpaper management

---

## Recovery Procedures

### If a Package Fails to Install

```bash
# Check if the package name is correct
pacman -Ss <package-name>

# Sync the package database first
sudo pacman -Sy

# Retry installation
sudo pacman -S <package-name>
```

### If a Service Fails to Enable

```bash
# Check the service status
systemctl status <service-name>

# View recent journal entries for the service
journalctl -u <service-name> -n 50

# Verify the package providing the service is installed
pacman -Qs <package-name>
```

### If the Shell Environment Is Broken

The shell configuration files modified by Layer 1 are:
- `~/.bash_profile` — login shell environment
- `~/.bashrc` — interactive shell settings

If your shell is broken after Layer 1:

```bash
# Open a recovery shell (press Ctrl+Alt+F2 for a TTY)
# Login as your user

# Restore bash_profile from backup
cp ~/.bash_profile.bak ~/.bash_profile

# Or temporarily bypass your profile
bash --norc --noprofile
```

Layer 1 backs up any existing shell files before modifying them with a `.bak`
suffix.

### Full Layer 1 Reset

If you want to re-run Layer 1 from scratch:

```bash
# The install script is idempotent — running it again is safe.
# Already-installed packages will be skipped.
# Already-enabled services will be skipped.
# Already-existing directories will be skipped.
bash install/install.sh
```

---

## Verifying the Installation

Run the verification script at any time to check the state of the system:

```bash
bash install/verify.sh
```

The verification script checks:
- Required commands are available in PATH
- Required services are active
- Required directories exist
- Environment variables are set correctly

A passing verification looks like:

```
[INFO]  Running Layer 1 verification...
[ OK ]  git is available.
[ OK ]  curl is available.
[ OK ]  NetworkManager.service is active.
[ OK ]  /home/user/.config exists.
[ OK ]  EDITOR is set to nvim.
[INFO]  All checks passed. Layer 1 is complete.
```

---

## Getting Help

1. Check [`troubleshooting.md`](troubleshooting.md) for known issues
2. Check the Arch Wiki — it is the most comprehensive Linux documentation available
3. Open an issue on the repository with your system details and the error output
