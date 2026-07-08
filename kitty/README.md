# kitty/

This directory will contain the Kitty terminal emulator configuration.

Kitty is a GPU-accelerated terminal emulator with support for true color, font
ligatures, keyboard protocols, and image rendering. It serves as the primary
terminal for this desktop environment.

This directory is **empty in Layers 1–3**. It will be populated in **Layer 4**.

---

## Planned Structure

```
kitty/
├── README.md
├── kitty.conf            ← Main configuration file
└── themes/
    └── main.conf         ← Color scheme (imported by kitty.conf)
```

---

## Why Kitty?

Kitty was chosen over alternatives (Alacritty, foot, wezterm) for:

- **GPU rendering** — smooth scrolling and rendering even with large outputs
- **Kitty graphics protocol** — native image display in the terminal
- **Keyboard protocol** — enhanced keyboard input for terminal applications
- **Font ligatures** — support for programming ligature fonts
- **Session management** — built-in tab and window management
- **Extensible** — kittens (plugins) for SSH, diff, and custom behaviors

---

## Layer 4 Responsibilities (Kitty)

Layer 4 will configure:

- Font family, size, and ligature settings
- Color scheme (matching the overall theme)
- Padding and spacing
- Scrollback buffer size
- Cursor style and blinking
- URL handling (open links with keyboard shortcut)
- Shell integration (Zsh prompt integration)
