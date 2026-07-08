# project_arch

> A handcrafted Arch Linux + Hyprland desktop environment built from first principles.

---

## Overview

**project_arch** is a fully documented, modular, and maintainable Arch Linux desktop configuration built entirely from scratch. Every file in this repository was written by hand with a clear purpose. Nothing was copied from existing dotfiles without being understood first.

This is not a theme pack or a rice template. It is an engineering project that happens to configure a desktop environment.

---

## Vision

The goal is to build a desktop environment that is:

- **Understood** — every setting has a documented reason for existing
- **Reproducible** — a fresh system can be fully configured from this repository in a single session
- **Maintainable** — future changes are easy to make without breaking unrelated parts
- **Extensible** — adding new tools or configurations follows an obvious pattern

This project is built the way production software is built: with structure, documentation, and discipline.

---

## Philosophy

| Principle | Application |
|---|---|
| No magic | Every configuration value is explained |
| No copies | Nothing is blindly borrowed from other dotfiles |
| Modular | Each tool lives in its own directory with its own documentation |
| Documented | No undocumented file enters the repository |
| Readable over clever | Clear code that a new contributor can understand |
| Minimal footprint | Install only what is needed and justified |

---

## Features

- **Layer 0** — Professional repository foundation with full documentation
- **Layer 1** — Automated base system preparation for a fresh Arch Linux installation
- **Layer 2** *(planned)* — Wayland compositor setup with Hyprland
- **Layer 3** *(planned)* — Status bar, application launcher, and notification daemon
- **Layer 4** *(planned)* — Terminal emulator and shell configuration
- **Layer 5** *(planned)* — GTK theming, fonts, and visual polish

---

## Repository Layout

```
project_arch/
├── README.md               ← You are here
├── LICENSE                 ← MIT License
├── .gitignore              ← Patterns excluded from version control
│
├── docs/                   ← Project-wide documentation
│   ├── architecture.md     ← System architecture and layer design
│   ├── roadmap.md          ← Development roadmap and milestones
│   ├── conventions.md      ← All naming, code, and commit conventions
│   ├── installation.md     ← End-to-end installation guide
│   └── troubleshooting.md  ← Common problems and their solutions
│
├── install/                ← Layer 1: Base system installation scripts
│   ├── README.md
│   ├── install.sh          ← Main entry point, orchestrates all others
│   ├── variables.sh        ← Shared variables and constants
│   ├── packages.sh         ← Package installation
│   ├── services.sh         ← Systemd service management
│   ├── directories.sh      ← Standard directory creation
│   ├── shell.sh            ← Base shell configuration
│   └── verify.sh           ← Post-installation verification
│
├── scripts/                ← Utility and maintenance scripts
│
├── hypr/                   ← Layer 2: Hyprland compositor configuration
├── waybar/                 ← Layer 3: Status bar configuration
├── rofi/                   ← Layer 3: Application launcher configuration
├── dunst/                  ← Layer 3: Notification daemon configuration
├── kitty/                  ← Layer 4: Terminal emulator configuration
├── gtk/                    ← Layer 5: GTK theming
├── themes/                 ← Layer 5: Color schemes and theme assets
└── wallpapers/             ← Wallpaper collection
```

---

## Development Roadmap

| Layer | Name | Status | Description |
|---|---|---|---|
| 0 | Repository Foundation | ✅ Complete | Structure, documentation, conventions |
| 1 | Base System | ✅ Complete | Arch Linux base packages and system services |
| 2 | Compositor | 🔲 Planned | Hyprland, input, outputs, keybindings |
| 3 | Shell UI | 🔲 Planned | Waybar, Rofi, Dunst |
| 4 | Terminal | 🔲 Planned | Kitty, Zsh, shell plugins |
| 5 | Visual | 🔲 Planned | GTK themes, fonts, wallpapers, cursors |
| 6 | Applications | 🔲 Planned | Application defaults, MIME types, XDG config |
| 7 | Extras | 🔲 Planned | Scripts, utilities, system maintenance |

See [`docs/roadmap.md`](docs/roadmap.md) for detailed milestone descriptions.

---

## Repository Standards

All files in this repository follow strict standards documented in [`docs/conventions.md`](docs/conventions.md). A brief summary:

**Bash scripts**
- Strict mode (`set -euo pipefail`) is required
- Every function must be documented with a comment block
- No hardcoded paths — use variables defined in `variables.sh`

**Markdown files**
- Every directory must contain a `README.md`
- Headers use ATX style (`#`)
- Tables are used for structured data

**Git commits**
- Format: `type(scope): short description`
- Types: `feat`, `fix`, `docs`, `refactor`, `chore`
- Scope is the layer or directory being changed

---

## Git Workflow

This repository follows a lightweight feature-branch workflow.

```
main          ← stable, always deployable
└── layer/1   ← development branch for Layer 1
└── layer/2   ← development branch for Layer 2
└── fix/...   ← hotfix branches
└── docs/...  ← documentation-only changes
```

**Procedure:**
1. Branch from `main` using the naming convention above
2. Make small, focused commits
3. Open a pull request (or merge directly if working solo)
4. Delete the branch after merging

---

## Contributing

This repository is maintained as a personal engineering project, but contributions and suggestions are welcome.

**Before contributing:**
1. Read [`docs/conventions.md`](docs/conventions.md) in full
2. Read [`docs/architecture.md`](docs/architecture.md) to understand the layer design
3. Open an issue before making large changes

**Contribution checklist:**
- [ ] Code follows the Bash style guide
- [ ] New directories contain a `README.md`
- [ ] New scripts are added to the verification step
- [ ] Commit messages follow the format in `conventions.md`
- [ ] Documentation is updated alongside code

---

## Quick Start

For a full installation guide see [`docs/installation.md`](docs/installation.md).

```bash
# Clone the repository
git clone https://github.com/your-username/project_arch.git
cd project_arch

# Review what will be installed
cat install/README.md

# Run the base system installer (Layer 1)
bash install/install.sh
```

> **Warning:** Read all scripts before executing them on a real system. Understand what each one does.

---

## License

This project is licensed under the MIT License. See [`LICENSE`](LICENSE) for the full text.

---

*Built with discipline. Documented with care. Understood completely.*
