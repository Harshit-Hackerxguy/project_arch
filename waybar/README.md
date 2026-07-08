# waybar/

This directory will contain the Waybar status bar configuration.

Waybar is a highly customizable Wayland bar that displays system information,
workspace indicators, media controls, clock, and other status widgets. It is
the primary information display layer of this desktop environment.

This directory is **empty in Layers 1 and 2**. It will be populated in **Layer 3**.

---

## Planned Structure

```
waybar/
├── README.md
├── config.jsonc          ← Module layout and widget configuration
└── style.css             ← Visual styling for all bar elements
```

---

## Why Waybar?

Waybar was chosen over alternatives (eww, ags, swaybar) for:

- **Native Hyprland support** — workspace module integrates with Hyprland IPC
- **JSON configuration** — structured, readable, and version-control friendly
- **CSS styling** — familiar styling language with full flexbox support
- **Module ecosystem** — large number of built-in modules for common use cases
- **Stability** — mature project with predictable release cycle

---

## Layer 3 Responsibilities (Waybar)

Layer 3 will configure:

- Bar position, height, and margins
- Workspace indicator module with Hyprland IPC
- System tray
- Clock and calendar popup
- Network status
- Audio volume (via PipeWire/PulseAudio)
- CPU and memory indicators
- Battery status (if applicable)
- Custom scripts for system-specific indicators

Styling (colors, fonts, borders) will follow the theme defined in Layer 5.
An intermediate neutral theme will be used until Layer 5 is complete.
