# Master Color Palette: Cyber-Minimal Scandinavian

> The canonical source of truth for all color values in `project_arch`.
> Designed for a modern, calm, productivity-focused engineering workstation.

---

## Design Rationale

This palette merges the **calm, uncluttered elegance of Scandinavian minimalism** with **subtle cyberpunk neon accents**.

When spending 8–12 hours a day in a terminal and code editor, high contrast with stark white backgrounds or aggressive primary colors causes visual fatigue. This palette uses deep, muted slate-black surfaces (`#0B0F14` and `#111827`) as the foundation, ensuring that text and code syntax remain legible without eye strain.

Vibrant neon accents (**Electric Cyan** and **Violet**) are reserved strictly for interactive feedback, active window borders, focused workspace indicators, and critical system status metrics.

---

## Color Tokens

| Token Name | Hex Value | RGBA (80% Opacity) | RGBA (40% Opacity) | Usage & Semantic Role |
|---|---|---|---|---|
| `bg-primary` | `#0B0F14` | `rgba(11, 15, 20, 0.80)` | `rgba(11, 15, 20, 0.40)` | Desktop background, terminal background, base compositor tint |
| `bg-surface` | `#111827` | `rgba(17, 24, 39, 0.80)` | `rgba(17, 24, 39, 0.40)` | Waybar, Rofi launcher, Dunst notifications, editor panels |
| `bg-surface-elevated` | `#1E293B` | `rgba(30, 41, 59, 0.80)` | `rgba(30, 41, 59, 0.40)` | Hover states, active dropdowns, selected menu items |
| `accent-primary` | `#38BDF8` | `rgba(56, 189, 248, 0.80)` | `rgba(56, 189, 248, 0.40)` | Active window borders, Waybar workspace indicator, Rofi search ring |
| `accent-secondary` | `#8B5CF6` | `rgba(139, 92, 246, 0.80)` | `rgba(139, 92, 246, 0.40)` | Secondary buttons, secondary workspace active indicator, music controls |
| `text-primary` | `#E5E7EB` | `rgba(229, 231, 235, 0.80)` | `rgba(229, 231, 235, 0.40)` | Main body text, terminal foreground, active window titles |
| `text-secondary` | `#94A3B8` | `rgba(148, 163, 184, 0.80)` | `rgba(148, 163, 184, 0.40)` | Inactive workspace numbers, muted status indicators, timestamps |
| `text-disabled` | `#475569` | `rgba(71, 85, 105, 0.80)` | `rgba(71, 85, 105, 0.40)` | Disabled icons, unpopulated workspaces, background dividers |
| `status-success` | `#10B981` | `rgba(16, 185, 129, 0.80)` | `rgba(16, 185, 129, 0.40)` | System OK, battery charging, network connected, git clean |
| `status-warning` | `#F59E0B` | `rgba(245, 158, 11, 0.80)` | `rgba(245, 158, 11, 0.40)` | High CPU/RAM load, battery low (20-40%), git modified |
| `status-error` | `#F43F5E` | `rgba(244, 63, 94, 0.80)` | `rgba(244, 63, 94, 0.40)` | Critical notifications, network offline, battery critical (<20%) |

---

## Tool-Specific Application Rules

### 1. Hyprland (`hypr/decorations.conf` & `hypr/windowrules.conf`)
- **Active Border**: `rgba(38BDF8FF) rgba(8B5CF6FF) 45deg` (Smooth linear gradient between Electric Cyan and Violet).
- **Inactive Border**: `rgba(1E293B88)` (Subtle, semi-transparent slate gray).
- **Shadows**: `rgba(0B0F1499)`, radius `20px`, falloff `10px`, offset `0 4px`.

### 2. Waybar (`waybar/style.css`)
- **Bar Background**: `rgba(17, 24, 39, 0.75)` with `backdrop-filter: blur(12px)`.
- **Text Color**: `#E5E7EB`.
- **Active Workspace Pill**: Background `#38BDF8`, Text `#0B0F14` (High contrast inverted tag).
- **Urgent Workspace Pill**: Background `#F43F5E`, Text `#E5E7EB`.

### 3. Kitty Terminal (`kitty/themes/main.conf`)
- **Background**: `#0B0F14` at `0.85` opacity (allowing subtle desktop blur to bleed through).
- **Foreground**: `#E5E7EB`.
- **Cursor**: `#38BDF8` (Glowing electric cyan).
- **Selection**: `#1E293B` background with `#38BDF8` text.

### 4. Rofi Launcher (`rofi/themes/main.rasi`)
- **Window Background**: `rgba(17, 24, 39, 0.85)` with blur.
- **Border**: `2px solid #38BDF8`.
- **Selected Row**: `#1E293B` background with left border accent `#38BDF8`.

### 5. Dunst Notifications (`dunst/dunstrc`)
- **Low Urgency**: Background `#111827`, Border `#8B5CF6`, Text `#94A3B8`.
- **Normal Urgency**: Background `#111827`, Border `#38BDF8`, Text `#E5E7EB`.
- **Critical Urgency**: Background `#111827`, Border `#F43F5E`, Text `#E5E7EB`.
