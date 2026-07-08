# Architecture

This document describes the structural design of `project_arch` — how the
repository is organized, why it is organized that way, and how the components
relate to each other.

---

## Design Principle: Layered Installation

The desktop environment is built in **discrete layers**. Each layer has a
specific responsibility. No layer assumes that a layer above it has been
completed. This means:

- Layer 1 works without Layer 2 being configured
- Each layer can be tested and validated independently
- A failure at any layer is isolated and recoverable
- The installation can be paused at any layer boundary

This is the same principle used in good software architecture: separation of
concerns.

---

## Layer Definitions

```
┌────────────────────────────────────────────────────────────────────────┐
│  Layer 5: Visual Polish                                                │
│  GTK themes, icon themes, cursors, fonts, wallpapers                   │
├────────────────────────────────────────────────────────────────────────┤
│  Layer 4: Terminal Environment                                         │
│  Kitty, Zsh, shell plugins, prompt, aliases, functions                 │
├────────────────────────────────────────────────────────────────────────┤
│  Layer 3: Desktop Shell                                                │
│  Waybar, Rofi, Dunst, clipboard manager, screenshot tools              │
├────────────────────────────────────────────────────────────────────────┤
│  Layer 2: Compositor                                                   │
│  Hyprland, monitors, keybindings, workspaces, autostart                │
├────────────────────────────────────────────────────────────────────────┤
│  Layer 1: Base System                                                  │
│  Packages, services, directories, shell, environment variables         │
├────────────────────────────────────────────────────────────────────────┤
│  Layer 0: Repository Foundation                                        │
│  Structure, documentation, conventions, LICENSE                        │
└────────────────────────────────────────────────────────────────────────┘
            ▲ Each layer depends on all layers below it ▲
```

---

## Component Map

The following table shows which configuration directory handles which
system component, and in which layer that component is addressed.

| Directory | Component | Layer |
|---|---|---|
| `install/` | Base system scripts | 1 |
| `hypr/` | Hyprland compositor | 2 |
| `waybar/` | Status bar | 3 |
| `rofi/` | Application launcher | 3 |
| `dunst/` | Notifications | 3 |
| `kitty/` | Terminal emulator | 4 |
| `gtk/` | Application theming | 5 |
| `themes/` | Shared design tokens | 5 |
| `wallpapers/` | Desktop background | 5 |
| `scripts/` | Cross-cutting utilities | All |
| `docs/` | Project documentation | All |

---

## Installation Flow

The following describes the intended execution sequence for a full installation
from a minimal Arch Linux base.

```
[Arch ISO]
    │
    ▼
[archinstall / manual install]   ← Arch Linux base installation (not in scope)
    │
    ▼
[Layer 1: install/install.sh]    ← Packages, services, directories, shell, env
    │
    ▼
[Layer 2: hypr/install.sh]       ← Hyprland, Wayland session (future)
    │
    ▼
[Layer 3: shell UI install]      ← Waybar, Rofi, Dunst (future)
    │
    ▼
[Layer 4: terminal install]      ← Kitty, Zsh (future)
    │
    ▼
[Layer 5: visual install]        ← GTK, fonts, cursors, wallpapers (future)
    │
    ▼
[Fully Configured Desktop]
```

---

## Dependency Relationships

### Layer 1 → Layer 2

Layer 2 (Hyprland) requires:
- A working Wayland session (provided by Layer 1 packages)
- A user with a home directory and XDG directories (Layer 1 directories)
- Environment variables set for Wayland (Layer 1 shell configuration)

### Layer 2 → Layer 3

Layer 3 components (Waybar, Rofi, Dunst) require:
- Hyprland running and providing IPC (Layer 2)
- A working notification server slot (only one can run at a time)

### Layer 3 → Layer 4

Layer 4 (Kitty, Zsh) requires:
- A Wayland compositor to create windows (Layer 2)
- Font packages installed (Layer 1)

### Layer 4 → Layer 5

Layer 5 (GTK, themes) applies visual styling to all components across layers
2–4. It is applied last because it does not affect functionality, only appearance.

---

## Configuration Organization Principle

Each tool's configuration lives in its own top-level directory. Configuration
for different tools is never mixed in the same directory.

**Rationale:** When you want to modify Rofi, you go to `rofi/`. You do not need
to search through a flat directory of hundreds of files.

---

## Shared Resources

Some resources are shared across multiple layers:

- **`themes/tokens/`** — Color values exported in multiple formats (CSS, shell, rasi)
- **`scripts/`** — Utility scripts usable across all layers
- **`docs/`** — Documentation for the project as a whole

When a resource is shared, it lives in the most general directory that makes
sense, not duplicated in each consumer's directory.

---

## What This Architecture Is Not

- This is not a NixOS-style declarative system
- This is not fully automated or idempotent in all respects
- This does not use a configuration management tool like Ansible or Chef
- Symlink management (like `stow`) may be introduced in a later layer but is
  not a requirement

The goal is a readable, maintainable shell-scripted installation that any
Linux engineer can understand and modify without specialized tooling.
