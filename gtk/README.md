# gtk/

This directory will contain GTK theming configuration.

GTK (GIMP Toolkit) is the widget toolkit used by a large portion of Linux
desktop applications. Proper GTK configuration ensures that application
windows, dialogs, buttons, and controls match the visual style of the
desktop environment.

This directory is **empty in Layers 1–4**. It will be populated in **Layer 5**.

---

## Planned Structure

```
gtk/
├── README.md
├── gtk-3.0/
│   └── settings.ini      ← GTK 3 application settings
├── gtk-4.0/
│   └── settings.ini      ← GTK 4 application settings
└── cursors/
    └── README.md         ← Cursor theme documentation
```

---

## What GTK Configuration Controls

- **Theme name** — the visual style applied to GTK application widgets
- **Icon theme** — icon pack used throughout the desktop
- **Cursor theme** — mouse cursor appearance and size
- **Font** — default font for GTK application UI elements
- **Prefer dark mode** — signals to applications that dark variants are preferred

---

## Layer 5 Responsibilities (GTK)

Layer 5 will configure:

- GTK 3 and GTK 4 settings files
- Icon theme selection and fallback
- Cursor theme and size
- Application font and scaling
- Dark mode preference propagation
- Integration with the compositor's color palette

> **Note:** This project does not maintain a custom GTK theme.
> It will select and configure an existing theme that fits the visual design.
> Theme selection will be documented with the rationale for the choice.
