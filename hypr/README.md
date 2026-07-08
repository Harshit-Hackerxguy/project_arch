# hypr/

This directory will contain the complete Hyprland compositor configuration.

Hyprland is a dynamic tiling Wayland compositor that provides the core visual
and interaction layer of this desktop environment. It manages windows, workspaces,
animations, input devices, monitors, and keybindings.

This directory is **empty in Layer 1**. It will be populated in **Layer 2**.

---

## Planned Structure

```
hypr/
├── README.md
├── hyprland.conf         ← Main entry point, imports all modules
├── monitors.conf         ← Monitor layout and resolution
├── keybindings.conf      ← All keyboard shortcuts
├── input.conf            ← Keyboard, mouse, and touchpad settings
├── workspaces.conf       ← Workspace rules and assignments
├── windowrules.conf      ← Per-application window rules
├── autostart.conf        ← Programs launched on compositor start
├── animations.conf       ← Animation curves and durations
├── decorations.conf      ← Borders, shadows, rounding
└── environment.conf      ← Environment variables set by Hyprland
```

---

## Why Hyprland?

Hyprland was chosen over alternatives (Sway, river, niri) for the following reasons:

- **Dynamic tiling** — supports both tiling and floating without mode-switching
- **Native animations** — smooth, configurable animations without a compositor
- **Active development** — frequent releases with a responsive maintainer community
- **IPC interface** — scriptable via `hyprctl` for automation
- **Wayland-native** — built for Wayland rather than ported from X11

---

## Layer 2 Responsibilities

Layer 2 will configure:

- Monitor outputs and resolutions
- Keyboard layout and repeat rate
- Workspace layout and naming
- All keybindings
- Autostart applications
- Visual decorations (borders, gaps, rounding)
- Animation configuration

Layer 2 will **not** configure:

- Application appearance (GTK theming — Layer 5)
- Status bar (Waybar — Layer 3)
- Launcher (Rofi — Layer 3)
- Notifications (Dunst — Layer 3)
