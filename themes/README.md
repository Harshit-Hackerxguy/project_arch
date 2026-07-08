# themes/

This directory contains color schemes, theme tokens, and visual design assets
used across multiple components of the desktop environment.

Centralizing theme data here allows all layers to share the same design system
without duplicating color values or visual constants across multiple files.

This directory is **empty in Layers 1–4**. It will be populated in **Layer 5**.

---

## Planned Structure

```
themes/
├── README.md
├── palette.md            ← Master color palette with hex values and usage notes
├── typography.md         ← Font choices, sizes, and rendering settings
└── tokens/
    ├── colors.sh         ← Shell-exportable color variables
    ├── colors.rasi       ← Rofi-format color variables
    └── colors.css        ← CSS custom properties for Waybar
```

---

## Design System Approach

Rather than configuring colors separately in each tool (Waybar CSS, Rofi rasi,
Dunst INI, Kitty conf), Layer 5 will establish a **single source of truth** for
all color values in `palette.md`.

The `tokens/` directory will contain format-specific exports of those values.
Each tool imports only the token file it needs.

This means changing the accent color requires editing **one file**, and the
change propagates to all tools.

---

## Layer 5 Responsibilities (Themes)

Layer 5 will establish:

- A master color palette (background, surface, border, text, accent colors)
- Typography choices (fonts for UI, terminal, and monospace contexts)
- Format-specific token exports
- Documentation of the visual design rationale
