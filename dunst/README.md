# dunst/

This directory will contain the Dunst notification daemon configuration.

Dunst is a lightweight and customizable notification daemon. It receives
desktop notifications from applications via the D-Bus notification protocol
and displays them as styled popups on the screen.

This directory is **empty in Layers 1 and 2**. It will be populated in **Layer 3**.

---

## Planned Structure

```
dunst/
├── README.md
└── dunstrc               ← Single-file Dunst configuration
```

---

## Why Dunst?

Dunst was chosen over alternatives (mako, swaync) for:

- **Lightweight** — minimal resource footprint
- **Single config file** — simple, flat INI-style configuration
- **Rule system** — per-application or per-urgency display rules
- **Script hooks** — run scripts on notification events (on-open, on-close)
- **Maturity** — well-tested and stable

---

## Layer 3 Responsibilities (Dunst)

Layer 3 will configure:

- Notification position and geometry
- Timeout by urgency level (low / normal / critical)
- Per-application display rules
- Font and icon settings
- Color scheme matching the desktop theme
- Action bindings (dismiss, open URL, etc.)
- History and recall behavior
