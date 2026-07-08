# Typography Hierarchy & Font Rules

> The typography system for `project_arch`.
> Focuses on developer legibility, ligature support, and clean Scandinavian hierarchy.

---

## Font Family Choices

### 1. Monospace & Terminal: **JetBrains Mono Nerd Font**
- **Why**: Designed explicitly for software engineers. Features increased height for lowercase letters, distinct character differentiation (`0` vs `O`, `1` vs `l` vs `I`), and exceptional programming ligatures (`->`, `=>`, `!=`, `===`, `>=`).
- **Nerd Font Patch**: Includes custom glyphs and icons required by Starship/custom prompts, eza file icons, Neovim statuslines (lualine), and Waybar workspace icons.
- **Where Used**: Kitty terminal, Neovim code buffers, Rofi search inputs, Dunst code blocks, Waybar clock and numerical indicators.

### 2. Interface & System UI: **Inter (or Noto Sans as Fallback)**
- **Why**: A highly readable neo-grotesque typeface designed specifically for computer screens and user interfaces. Features optical sizing, clear numerals, and neutral geometric proportions that embody Scandinavian minimalism.
- **Where Used**: GTK 3/4 application interfaces, Waybar text labels, Rofi application grid titles, Dunst notification headings and body text.

---

## Type Scale & Sizing

| Element / Context | Font Family | Size (px / pt) | Weight | Line Height | Letter Spacing |
|---|---|---|---|---|---|
| **Compositor Window Titles** | Inter | `11pt` | Medium (500) | `1.2` | `+0.01em` |
| **Waybar Workspace Indicators** | JetBrains Mono NF | `13pt` | Bold (700) | `1.0` | `0` |
| **Waybar Status Widgets** | JetBrains Mono NF | `11pt` | Medium (500) | `1.0` | `-0.01em` |
| **Terminal Code Buffer (4K UI)** | JetBrains Mono NF | `12pt` / `16px` | Regular (400) | `1.4` | `0` |
| **Terminal Status / Prompt** | JetBrains Mono NF | `12pt` | Bold (700) | `1.2` | `0` |
| **Rofi App Title Grid** | Inter | `11pt` | Medium (500) | `1.3` | `0` |
| **Rofi Search Input** | JetBrains Mono NF | `14pt` | Regular (400) | `1.2` | `0` |
| **Dunst Notification Title** | Inter | `11pt` | Bold (700) | `1.3` | `0` |
| **Dunst Notification Body** | Inter | `10pt` | Regular (400) | `1.4` | `0` |

---

## Rendering & Hinting Configuration

To ensure crisp typography on high-resolution 4K displays without blurring or color fringing, font rendering is configured via fontconfig (`~/.config/fontconfig/fonts.conf` in Layer 5):

- **Antialiasing**: `true` (Enabled for smooth diagonal strokes).
- **Hinting**: `true` (Enabled for crisp grid alignment).
- **Hint Style**: `slight` (Prevents geometric distortion of modern web/UI typefaces like Inter).
- **Subpixel Rendering (RGBA)**: `rgb` (Standard RGB subpixel order for LCD/OLED panels).
- **LCD Filter**: `lcddefault` (Prevents color fringing on fine ligature stems).

---

## Ligature Rules

In programming editors (Neovim / VS Code) and Kitty terminal:
- **Enabled Ligatures**: Arrow operators (`->`, `<-`, `=>`), comparison operators (`==`, `!=`, `<=`, `>=`), logical operators (`&&`, `||`), and Markdown headers (`#`, `##`).
- **Cursor Overrides**: When the terminal or editor cursor is placed directly over a ligature, the glyph must unpack into its individual characters to allow precise character-level editing.
