# wallpapers/

This directory is a placeholder for the wallpaper collection used with this
desktop environment.

---

## Why Wallpapers Are Not Committed

Wallpaper images are binary files. Binary files:

- Cannot be meaningfully diff'd in Git
- Bloat repository size quickly
- Are not useful to most people cloning the repository

For this reason, wallpapers are excluded from version control via `.gitignore`.

---

## How Wallpapers Are Managed

Wallpapers should be sourced and placed in this directory manually after
cloning the repository. The `install/` scripts will create this directory
but will not populate it.

Recommended sources for high-quality wallpapers:

- [unsplash.com](https://unsplash.com) — royalty-free photography
- [wallhaven.cc](https://wallhaven.cc) — curated community collection
- Your own photography or artwork

---

## Expected Structure

```
wallpapers/
├── README.md
├── previews/             ← Small thumbnails ARE committed for documentation
│   └── *.jpg
└── *.jpg / *.png / *.webp   ← Full-size wallpapers (gitignored)
```

---

## Wallpaper Tool

Layer 2 will configure `swww` (Simple Wayland Wallpaper) as the wallpaper
daemon. It supports smooth animated transitions between wallpapers and
integrates well with Hyprland.

A helper script will be provided in `scripts/` to rotate wallpapers randomly
or on a schedule.

---

## Previews

Small preview thumbnails (under 100KB) may be committed to the `previews/`
subdirectory and used in documentation. Full-resolution images must not be
committed.
