# install/

This directory contains the Layer 1 installation scripts for `project_arch`.

Layer 1 is responsible for preparing a fresh Arch Linux base installation to a
state where a desktop environment can be installed. It does **not** install or
configure Hyprland, Waybar, or any other desktop component.

---

## What Layer 1 Installs

- Essential development tools (`git`, `base-devel`, `make`, `cmake`)
- Build utilities required for compiling AUR packages
- Networking utilities (`curl`, `wget`, `networkmanager`)
- Terminal utilities (`neovim`, `ripgrep`, `fd`, `bat`, `eza`, `fzf`)
- Archive tools (`tar`, `unzip`, `p7zip`, `zstd`)
- Font packages required by later layers
- System monitoring tools (`htop`, `btop`)
- A working AUR helper (`paru`)

## What Layer 1 Enables

- `NetworkManager.service` — network management
- `bluetooth.service` — Bluetooth support
- `fstrim.timer` — periodic SSD TRIM for drive health
- `reflector.timer` — automatic mirror list updates (if reflector is installed)

## What Layer 1 Configures

- Standard XDG user directories (`~/.config`, `~/.local/share`, etc.)
- Project-specific directories
- Base shell environment variables (`EDITOR`, `BROWSER`, `XDG_*`)
- Bash profile additions for a clean shell environment

---

## Script Overview

| Script | Purpose | Run Directly? |
|---|---|---|
| `install.sh` | Main orchestrator — run this | Yes |
| `variables.sh` | Shared constants and logging functions | No (sourced) |
| `packages.sh` | Package installation | Yes (standalone) |
| `services.sh` | Systemd service management | Yes (standalone) |
| `directories.sh` | Directory creation | Yes (standalone) |
| `shell.sh` | Base shell configuration | Yes (standalone) |
| `verify.sh` | Post-install verification | Yes (standalone) |

---

## Running the Installation

```bash
# Full installation (recommended)
bash install/install.sh

# Individual modules (for debugging or partial installs)
source install/variables.sh   # load shared variables first
bash install/packages.sh
bash install/services.sh
bash install/directories.sh
bash install/shell.sh
bash install/verify.sh
```

---

## Installation Order

The scripts must be run in the following order. The orchestrator handles this
automatically.

```
1. variables.sh   ← defines constants used by all other scripts
2. packages.sh    ← installs packages (services depend on packages)
3. services.sh    ← enables services (requires packages to be installed)
4. directories.sh ← creates directories (shell config may reference them)
5. shell.sh       ← configures environment (references the above)
6. verify.sh      ← checks everything is in order
```

---

## Design Decisions

### Why separate scripts instead of one big script?

Each script has a single responsibility. If package installation fails, you can
re-run only `packages.sh` without touching services or directories. This makes
debugging faster and makes the code easier to read.

### Why `set -euo pipefail`?

These flags make the scripts fail loudly and immediately when something goes
wrong. Without them, a script can silently continue after a failure and leave
the system in a partially configured state. See `docs/conventions.md` for
a detailed explanation.

### Why not use an Ansible playbook?

This project deliberately avoids external tooling dependencies. Any system with
Bash can run these scripts. The goal is maximum portability with minimum
prerequisites.

---

## Adding New Packages or Services

1. Add the package to the appropriate array in `packages.sh`
2. Add a comment explaining why the package is needed
3. If a service needs to be enabled, add it to `services.sh`
4. Add a verification check in `verify.sh`
5. Update this README if the addition changes Layer 1's scope significantly
