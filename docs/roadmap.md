# Roadmap

This document tracks the development status and planned milestones for
`project_arch`. It is updated as layers are completed.

---

## Status Legend

| Symbol | Meaning |
|---|---|
| ✅ | Complete |
| 🔧 | In progress |
| 🔲 | Planned |
| ⏸ | Deferred |

---

## Layer 0 — Repository Foundation

**Status:** ✅ Complete

The repository has a defined structure, comprehensive documentation, coding
conventions, a license, and a gitignore.

### Deliverables

- [x] Root `README.md` with project overview
- [x] `LICENSE` (MIT)
- [x] `.gitignore` with documented patterns
- [x] All top-level directories created with `README.md`
- [x] `docs/architecture.md`
- [x] `docs/roadmap.md`
- [x] `docs/conventions.md`
- [x] `docs/installation.md`
- [x] `docs/troubleshooting.md`

---

## Layer 1 — Base System

**Status:** ✅ Complete

A fresh Arch Linux installation can be brought to a ready state using the
scripts in `install/`.

### Deliverables

- [x] `install/variables.sh` — shared constants
- [x] `install/packages.sh` — essential package installation
- [x] `install/services.sh` — systemd service management
- [x] `install/directories.sh` — XDG and custom directory creation
- [x] `install/shell.sh` — base shell environment configuration
- [x] `install/verify.sh` — post-installation verification
- [x] `install/install.sh` — main orchestrator
- [x] `install/README.md`

---

## Layer 2 — Compositor

**Status:** 🔲 Planned

**Scope:** Hyprland compositor configuration — monitors, keybindings,
workspaces, window rules, autostart, animations, and decorations.

### Planned Deliverables

- [ ] `hypr/hyprland.conf` — main configuration entry point
- [ ] `hypr/monitors.conf` — monitor layout and resolution
- [ ] `hypr/keybindings.conf` — all keyboard shortcuts
- [ ] `hypr/input.conf` — keyboard and pointer device settings
- [ ] `hypr/workspaces.conf` — workspace assignments and rules
- [ ] `hypr/windowrules.conf` — per-application rules
- [ ] `hypr/autostart.conf` — startup programs
- [ ] `hypr/animations.conf` — animation configuration
- [ ] `hypr/decorations.conf` — borders, shadows, rounding
- [ ] `hypr/environment.conf` — Wayland environment variables
- [ ] `hypr/README.md` updated with actual configuration details

### Prerequisites

- Layer 1 complete
- `hyprland`, `hyprutils`, `hypridle`, `hyprlock` packages available

---

## Layer 3 — Desktop Shell

**Status:** 🔲 Planned

**Scope:** Status bar (Waybar), application launcher (Rofi), notification
daemon (Dunst), screenshot tools, clipboard manager.

### Planned Deliverables

- [ ] `waybar/config.jsonc`
- [ ] `waybar/style.css`
- [ ] `rofi/config.rasi`
- [ ] `rofi/themes/main.rasi`
- [ ] `rofi/scripts/powermenu.sh`
- [ ] `rofi/scripts/clipboard.sh`
- [ ] `dunst/dunstrc`
- [ ] Screenshot integration (`grimblast` or `grim` + `slurp`)
- [ ] Clipboard manager integration (`cliphist`)

### Prerequisites

- Layer 2 complete (Hyprland must be running for Wayland bar and launcher)

---

## Layer 4 — Terminal Environment

**Status:** 🔲 Planned

**Scope:** Kitty terminal, Zsh shell, plugin manager, prompt, aliases,
functions, and developer tooling configuration.

### Planned Deliverables

- [ ] `kitty/kitty.conf`
- [ ] `kitty/themes/main.conf`
- [ ] Zsh configuration (location TBD — possibly `zsh/` directory)
- [ ] Shell prompt (Starship or custom PS1)
- [ ] Shell aliases and functions
- [ ] Zsh plugin configuration
- [ ] Developer tool configuration (git, ssh, gpg)

### Prerequisites

- Layer 1 packages (Kitty, Zsh installed)
- Layer 2 (terminal needs a Wayland surface to open)

---

## Layer 5 — Visual Polish

**Status:** 🔲 Planned

**Scope:** GTK theming, icon themes, cursor themes, fonts, wallpaper setup,
and a shared color token system.

### Planned Deliverables

- [ ] `themes/palette.md` — master color palette
- [ ] `themes/typography.md` — font selections and settings
- [ ] `themes/tokens/colors.sh` — shell-format color variables
- [ ] `themes/tokens/colors.rasi` — Rofi-format color variables
- [ ] `themes/tokens/colors.css` — CSS custom properties
- [ ] `gtk/gtk-3.0/settings.ini`
- [ ] `gtk/gtk-4.0/settings.ini`
- [ ] Wallpaper setup script in `scripts/`
- [ ] Layer 3 and 4 configs updated to use theme tokens

### Prerequisites

- Layers 2–4 complete (theming requires components to exist)

---

## Layer 6 — Application Defaults (Deferred)

**Status:** ⏸ Deferred

**Scope:** MIME type associations, XDG default applications, browser
configuration, file manager setup.

This layer is deferred because application choice is highly personal and not
core to the compositor/shell setup. It will be scoped and scheduled after
Layer 5.

---

## Layer 7 — Scripts and Automation (Ongoing)

**Status:** 🔲 Planned (ongoing)

**Scope:** Repository maintenance scripts, system update helpers, backup
tools, and other utilities that span multiple layers.

Scripts in `scripts/` will be added incrementally throughout all layers as
maintenance needs are identified. A full inventory will be documented here
as they are created.

---

## Version Milestones

| Version | Description | Layers |
|---|---|---|
| v0.1.0 | Repository foundation | 0 |
| v0.2.0 | Functional base system | 0–1 |
| v0.3.0 | Working Wayland session | 0–2 |
| v0.4.0 | Full desktop shell | 0–3 |
| v0.5.0 | Terminal environment complete | 0–4 |
| v1.0.0 | Fully polished desktop | 0–5 |

---

## Known Limitations and Open Questions

- **swww vs. swaybg** — Wallpaper daemon not yet selected; decision deferred to Layer 2
- **Starship vs. custom prompt** — Shell prompt tool not yet decided; deferred to Layer 4
- **GNU Stow** — Whether to use symlink management is undecided; evaluate at Layer 2
- **Zsh location** — Zsh config may live in `zsh/` or merged with `kitty/`; TBD at Layer 4
