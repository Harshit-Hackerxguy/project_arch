# rofi/

This directory will contain the Rofi application launcher configuration.

Rofi is a window switcher, application launcher, and general-purpose menu tool
for Wayland (via rofi-wayland). It provides the primary keyboard-driven
interface for launching applications, switching windows, and running scripts.

This directory is **empty in Layers 1 and 2**. It will be populated in **Layer 3**.

---

## Planned Structure

```
rofi/
├── README.md
├── config.rasi           ← Base configuration and mode settings
├── themes/
│   └── main.rasi         ← Visual theme using Rofi's rasi format
└── scripts/
    ├── powermenu.sh      ← Custom power menu (shutdown, reboot, lock, suspend)
    └── clipboard.sh      ← Clipboard manager interface (via cliphist)
```

---

## Why Rofi?

Rofi was chosen over alternatives (wofi, tofi, fuzzel, bemenu) for:

- **Script extensibility** — custom modes can be written as simple shell scripts
- **rasi theming** — a dedicated styling language that gives precise visual control
- **Feature depth** — handles application launching, window switching, and custom menus
- **Keyboard-first** — designed for fast, keyboard-driven workflows

---

## Layer 3 Responsibilities (Rofi)

Layer 3 will configure:

- Application launcher (`rofi -show drun`)
- Window switcher (`rofi -show window`)
- Power menu script (lock, suspend, reboot, shutdown)
- Clipboard manager integration (via `cliphist | rofi -dmenu`)
- Consistent visual theme matching the overall desktop palette
