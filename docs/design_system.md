# Design System Specification: Cyber-Minimal Scandinavian

> The architectural and visual design specification for the `project_arch` desktop environment.
> Tailored for a high-performance, 4K software engineering workstation.

---

## 1. Aesthetic Philosophy

The visual language of `project_arch` rests on three foundational pillars:

1. **Scandinavian Minimalism**: Form follows function. Clean, balanced spacing with zero visual clutter. Every UI element exists to convey necessary state or facilitate a workflow. No superfluous widgetry or distracting animations.
2. **Subtle Cyberpunk Influence**: In an otherwise calm, dark slate environment (`#0B0F14` to `#111827`), precise neon accents—**Electric Cyan (`#38BDF8`)** and **Violet (`#8B5CF6`)**—act as high-contrast optical anchors. These neon accents illuminate active window borders, focused workspace pills, and critical notifications without overwhelming the user's vision.
3. **Handcrafted Engineering Quality**: The interface avoids the generic "default rice" appearance. Geometry, blur opacities, and animation bezier curves are mathematically tuned to create a cohesive, tactile glassmorphism that feels like custom-machined software hardware.

---

## 2. Desktop Geometry & Layout

### Resolution & Scale
- **Target Display**: 3840×2160 (4K UHD) at 16:9 aspect ratio.
- **DPI Scaling**: 1.5x or 2.0x integer/fractional scaling via Wayland compositor rules, ensuring crisp typography and retina-sharp UI borders.

### Waybar Status Bar (Top Floating)
- **Position**: Top of the screen, floating with `12px` top margin, `16px` left/right margins.
- **Height**: `40px` (proportional to 4K display resolution).
- **Border Radius**: `14px` (matching window geometry).
- **Surface Material**: `rgba(17, 24, 39, 0.75)` with `backdrop-filter: blur(16px)`.
- **Shadow**: Subtle drop shadow `0 4px 12px rgba(0, 0, 0, 0.45)`.
- **Layout Structure**:
  - **Left**: Arch Linux logo (`` in Electric Cyan), Workspace indicators (Numbered `1` through `4`, active tag highlighted in Electric Cyan).
  - **Center**: Current active application title and window class (muted soft white, truncated gracefully).
  - **Right**: Condensed, icon-prefixed system metrics — CPU load (``), RAM usage (``), Disk usage (`󰋊`), Network status (`󰤨`), Bluetooth (`󰂯`), Audio Volume (``), Brightness (`󰃠`), Battery (`󰁹`), Date & Clock (`󰥔`).

---

## 3. Window & Compositor Mechanics (Hyprland)

### Corner Radius & Borders
- **Border Radius**: `12px` (standardized across all windows, launchers, and popups).
- **Active Border Width**: `2px` (thin, razor-sharp precision).
- **Active Border Color**: Linear gradient from Electric Cyan (`#38BDF8`) to Violet (`#8B5CF6`) at a `45deg` angle.
- **Inactive Border Width**: `1px` (subtle separation).
- **Inactive Border Color**: Semi-transparent Slate Gray (`rgba(30, 41, 59, 0.5)`).

### Shadows & Depth
- **Window Shadows**: Enabled to create vertical separation against the dark background.
- **Shadow Range**: `20px` falloff.
- **Shadow Render Power**: `3` (smooth Gaussian falloff).
- **Shadow Color**: Deep obsidian `rgba(11, 15, 20, 0.85)`.

### Glassmorphism & Transparency
- **Active Window Opacity**: `0.95` (allows subtle background bleed without compromising text legibility).
- **Inactive Window Opacity**: `0.85` (visually recedes background tasks).
- **Background Blur**: `size: 8`, `passes: 3` (high-quality dual-kawase blur algorithm), with `noise: 0.0117` and `contrast: 0.89` for a frosted glass texture.

### Animations
- **Curve System**: Custom cubic-bezier curve `customBezier = 0.05, 0.9, 0.1, 1.05` (snappy start, gentle elastic deceleration).
- **Window Open/Close**: Fade and slight vertical scale (`0.95` to `1.0`) over `200ms`.
- **Workspace Switch**: Horizontal slide with subtle desaturation transition over `250ms`.

---

## 4. Component Stylings

### Kitty Terminal
- **Background Tint**: `#0B0F14` at `85%` opacity, utilizing compositor blur.
- **Padding**: `16px` inner window padding for an airy, uncrowded layout.
- **Font**: **JetBrains Mono Nerd Font** at `12pt` (`16px` at 4K scaling).
- **Workflow Layout**: Designed for seamless split-pane tiling (e.g., Neovim editing code on top/left, build terminal/server logs on bottom/right).
- **System Info Banner**: Configured with `fastfetch` using a custom minimal Arch ASCII logo in Electric Cyan and Violet key-value pairs.

### Rofi Application Launcher
- **Placement**: Absolutely centered on screen, floating overlay.
- **Dimensions**: Width `680px`, Max Height `480px`.
- **Search Header**: Top search bar with a glowing Electric Cyan border ring when focused, displaying a prompt icon `❯`.
- **Grid View**: Applications displayed in a clean 4-column icon grid with labels below icons.
- **Selection State**: Highlighted card with elevated background (`#1E293B`), `8px` rounding, and an Electric Cyan left indicator bar.

### Dunst Notification Daemon
- **Placement**: Top-right corner, floating `16px` below Waybar (`68px` from top edge).
- **Geometry**: Width `360px`, border radius `12px`, padding `16px`.
- **Visual Style**: Frosted glass surface (`#111827` at `80%` opacity with blur).
- **Color Coding**:
  - *Info/Normal*: Electric Cyan (`#38BDF8`) left accent strip.
  - *Warning*: Amber (`#F59E0B`) left accent strip.
  - *Critical*: Rose (`#F43F5E`) border and glowing shadow.

---

## 5. Workspace Workflow Allocation

To maintain strict mental categorization, workspaces are mapped to fixed engineering contexts:

| Workspace | Name | Primary Applications | Layout Strategy |
|---|---|---|---|
| **WS 1** | `1: CODE` | Neovim / VS Code (C++ project), Kitty terminal | Left 60% Code Editor, Right 40% stacked terminal split |
| **WS 2** | `2: WEB` | Firefox / Chromium (Dev docs, API references, GitHub) | Tabbed / maximized browser window for reading focus |
| **WS 3** | `3: FILES` | Yazi (CLI file manager) or Thunar, Git clients | Tiled two-pane view for file operations and git inspection |
| **WS 4** | `4: COMMS` | Discord, Slack, Spotify, Email client | Grid layout (2×2 or vertical split) for background monitoring |
| **WS 5–10** | `5+` | Empty / Scratchpad | Dynamically allocated for temporary virtualization or testing |

---

## 6. Lighting & Environmental Polish

- **Wallpaper**: High-resolution 4K dark mountain landscape at night, featuring soft atmospheric fog and a gentle blue-to-purple aurora borealis. Provides natural contrast against the sharp geometric window borders.
- **Monitor Reflections**: Dark surface palettes prevent harsh screen glare in low-light programming rooms.
- **Eye Strain Reduction**: Color temperatures and brightness thresholds are optimized for continuous nighttime development sessions without relying on aggressive yellow blue-light filters that distort syntax highlighting colors.
