# Conventions

This document defines all standards used in `project_arch`. It is the single
authoritative reference for how code, documentation, commits, and files are
structured in this repository.

Every contributor (or future maintainer) should read this document in full
before making any changes.

---

## Table of Contents

1. [Naming Conventions](#naming-conventions)
2. [Folder Organization](#folder-organization)
3. [Markdown Style](#markdown-style)
4. [Bash Style Guide](#bash-style-guide)
5. [Comment Style](#comment-style)
6. [Git Branch Strategy](#git-branch-strategy)
7. [Commit Message Format](#commit-message-format)
8. [Documentation Rules](#documentation-rules)
9. [Design Philosophy](#design-philosophy)

---

## Naming Conventions

### Files

| Type | Convention | Example |
|---|---|---|
| Shell scripts | `snake_case.sh` | `install_packages.sh` |
| Markdown docs | `snake_case.md` | `troubleshooting.md` |
| Config files | Follow tool convention | `kitty.conf`, `dunstrc` |
| JSON configs | `snake_case.jsonc` | `config.jsonc` |
| CSS files | `snake_case.css` | `style.css` |

**Rules:**
- Never use spaces in file or directory names
- Prefer lowercase for everything except tool-mandated names
- Use hyphens in Git branch names, underscores in file names

### Variables

#### Bash Variables

| Scope | Convention | Example |
|---|---|---|
| Constants / globals | `SCREAMING_SNAKE_CASE` | `INSTALL_DIR` |
| Local function vars | `snake_case` | `package_name` |
| Loop variables | Short descriptive | `pkg`, `svc`, `dir` |

```bash
# Good
readonly CONFIG_DIR="${HOME}/.config"
local package_count=0
for pkg in "${PACKAGES[@]}"; do ...

# Bad
configDir="$HOME/.config"
PACKAGECOUNT=0
for i in "${PACKAGES[@]}"; do ...
```

### Functions

- Use `snake_case` for all function names
- Prefix with the script's module name where disambiguation is needed
- Functions should do **one thing** and be named to reflect that

```bash
# Good
install_packages()    # installs packages
enable_services()     # enables services
create_directories()  # creates directories

# Bad
do_stuff()
main2()
step3()
```

### Directories

- `snake_case` for multi-word directories (though most are single words)
- Every directory must contain a `README.md`
- Group related files — do not create directories for single files

---

## Folder Organization

### Top-Level Rule

The top-level directory maps exactly to **system components**. One directory
per tool or concern. No flat dumping of files.

### Nesting Depth

Keep nesting shallow. More than three levels of nesting is a warning sign.

```
hypr/                   ← good: one level for main configs
hypr/themes/            ← acceptable: two levels for sub-resources
hypr/themes/dark/       ← warning: three levels may be too deep
```

### What Goes Where

| Content | Location |
|---|---|
| Tool-specific config | That tool's directory |
| Shared constants | `themes/tokens/` |
| Cross-cutting scripts | `scripts/` |
| Installation scripts | `install/` |
| Project documentation | `docs/` |
| Tool documentation | Inside that tool's directory |

---

## Markdown Style

### Headings

- Use ATX-style headings (`#` prefix), never underline-style (`===`)
- H1 (`#`) is for the document title only — one per file
- H2 (`##`) for major sections
- H3 (`###`) for subsections
- Never skip heading levels

```markdown
# Document Title

## Major Section

### Subsection
```

### Formatting

- **Bold** for important terms, warnings, and UI elements
- *Italic* for technical terms being defined or file names in prose
- `Code` for all commands, paths, file names, and code references in prose
- Code blocks (fenced with triple backticks) for all multi-line code

### Tables

Use tables for structured comparisons, not prose lists.

```markdown
| Column A | Column B | Column C |
|---|---|---|
| value    | value    | value    |
```

### Lists

- Use bullet lists for unordered items with no inherent sequence
- Use numbered lists only when order matters (steps, procedures)
- Do not mix list styles within the same list

### Links

- Use descriptive link text — never "click here"
- Use relative paths for links within the repository
- Use full URLs for external links

```markdown
# Good
See [architecture.md](architecture.md) for the full design.

# Bad
See [here](architecture.md) for the full design.
```

### Code Blocks

Always specify the language for syntax highlighting.

````markdown
```bash
echo "Hello"
```
````

Supported language tags used in this project: `bash`, `jsonc`, `css`, `ini`,
`markdown`, `text`.

---

## Bash Style Guide

### Strict Mode

Every script that runs standalone must begin with:

```bash
set -euo pipefail
```

**What each flag does:**

| Flag | Name | Effect |
|---|---|---|
| `-e` | errexit | Exit immediately on any command failure |
| `-u` | nounset | Treat unset variables as errors |
| `-o pipefail` | pipefail | Pipeline fails if any command in it fails |

Without these flags, a script can silently continue after a failure and corrupt
system state. These flags make failure explicit and loud.

**Exception:** `variables.sh` and other sourced-only files should not call
`set -euo pipefail` directly — the calling script sets mode for the process.

### Script Header

Every standalone script must begin with a standard header:

```bash
#!/usr/bin/env bash
# =============================================================================
# Script Name: script_name.sh
# Description: A one-paragraph description of what this script does.
#
# Usage:       bash script_name.sh [options]
# Arguments:   Describe any positional arguments here.
# Environment: List any environment variables this script reads.
#
# Author:      project_arch contributors
# Layer:       Layer N — Layer Name
# =============================================================================
```

### Variable Quoting

Always quote variable expansions to prevent word-splitting and globbing.

```bash
# Good
echo "${MY_VAR}"
cp "${source}" "${dest}"

# Bad
echo $MY_VAR
cp $source $dest
```

### Arrays

Use indexed arrays for lists of values.

```bash
# Good
PACKAGES=(
    "git"
    "curl"
    "neovim"
)
for pkg in "${PACKAGES[@]}"; do
    pacman -S --noconfirm "${pkg}"
done

# Bad
PACKAGES="git curl neovim"
for pkg in $PACKAGES; do ...
```

### Functions

Every function must have a documentation comment immediately above it:

```bash
# install_package — installs a single pacman package.
# Arguments:
#   $1 — package name to install
# Returns:
#   0 on success, 1 if the package is not found
install_package() {
    local package_name="${1:?install_package: package name required}"
    pacman -S --noconfirm "${package_name}"
}
```

### Error Handling

- Use the `:?` parameter expansion for required arguments
- Log meaningful messages before exiting on error
- Use `|| { log_error "..."; exit 1; }` for critical commands

```bash
# Fail loudly with a message
pacman -Sy || { log_error "Failed to sync package database."; exit 1; }
```

### Output Formatting

Use consistent prefixed output functions defined in `variables.sh`:

```bash
log_info  "Installing packages..."      # [INFO]  Installing packages...
log_ok    "Git installed."              # [ OK ]  Git installed.
log_warn  "Package already installed."  # [WARN]  Package already installed.
log_error "pacman failed."              # [ERROR] pacman failed.
```

### Indentation

Use 4 spaces. Never tabs.

### Line Length

Prefer lines under 80 characters. Hard-wrap at 100 characters.

### Subshells and Command Substitution

Use `$()` for command substitution, never backticks.

```bash
# Good
current_user=$(whoami)

# Bad
current_user=`whoami`
```

---

## Comment Style

### Inline Comments

Use inline comments sparingly. Code should be self-explanatory. Comment the
*why*, not the *what*.

```bash
# Good: explains a non-obvious reason
sleep 2  # wait for D-Bus to initialize before sending a message

# Bad: restates what the code already says
echo "done"  # print "done"
```

### Section Separators

Use separator lines to divide logical sections within a script:

```bash
# -----------------------------------------------------------------------------
# Section Name
# -----------------------------------------------------------------------------
```

### Fixme and Todo

Use standardized tags:

```bash
# TODO(your-name): describe work that needs to be done
# FIXME(your-name): describe a known bug or incorrect behavior
# NOTE: explain something surprising or important for the reader
```

---

## Git Branch Strategy

### Branch Naming

| Purpose | Pattern | Example |
|---|---|---|
| Layer development | `layer/N-short-name` | `layer/2-hyprland` |
| Bug fix | `fix/short-description` | `fix/packages-missing-curl` |
| Documentation | `docs/short-description` | `docs/add-troubleshooting` |
| Chore / maintenance | `chore/short-description` | `chore/update-gitignore` |

### Rules

- Branch from `main`
- Keep branches focused — one concern per branch
- Delete branches after merging
- Never commit directly to `main` (except Layer 0 bootstrap)
- Always write a meaningful PR description (even when working solo)

---

## Commit Message Format

This project follows a subset of the Conventional Commits specification.

### Format

```
type(scope): short description in imperative mood

Optional body paragraph explaining why this change was made,
not what the change is (the diff already shows that).

Optional footer with references:
Closes #123
```

### Types

| Type | When to Use |
|---|---|
| `feat` | New feature or configuration |
| `fix` | Bug fix or correction |
| `docs` | Documentation changes only |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `chore` | Tooling, CI, build changes |
| `style` | Formatting changes with no functional impact |

### Scopes

Scope is the layer or directory being changed.

| Scope | Meaning |
|---|---|
| `root` | Root-level files (README, .gitignore) |
| `docs` | `docs/` directory |
| `install` | `install/` directory |
| `hypr` | `hypr/` directory |
| `waybar` | `waybar/` directory |
| `rofi` | `rofi/` directory |
| `dunst` | `dunst/` directory |
| `kitty` | `kitty/` directory |
| `gtk` | `gtk/` directory |
| `themes` | `themes/` directory |
| `scripts` | `scripts/` directory |

### Examples

```
feat(install): add base package list with rationale

docs(docs): add architecture layer diagram

fix(install): correct pipefail behavior in services.sh

chore(root): add wallpaper patterns to .gitignore
```

### Rules

- Subject line is under 72 characters
- Subject line does not end with a period
- Subject uses imperative mood ("add" not "added" or "adds")
- Body wraps at 72 characters
- Body explains *why*, not *what*

---

## Documentation Rules

1. Every directory must contain a `README.md` before any other files are added
2. Every script must have a header comment block
3. Every function must have a comment block
4. Non-obvious configuration values must be explained in an inline comment
5. Documentation must be updated in the same commit that changes the code
6. Do not leave placeholder content — write real content or leave the section out

---

## Design Philosophy

### Explicit over Implicit

Every setting that could have a default is set explicitly with a comment
explaining the choice. This ensures the intent is clear and defaults
cannot change silently.

### Small, Focused Files

One file per concern. A single file should not configure two different tools
or serve two different purposes. When a file grows large, split it.

### Stable Interfaces

Scripts should be designed so that their calling convention (arguments,
environment variables, exit codes) does not change after Layer 1 is merged.
Breaking changes require documentation and a version bump.

### Test Before Commit

Before committing a script change, run it (or at minimum run `bash -n` for
syntax checking and `shellcheck` for static analysis). Do not commit untested
scripts.

### No Premature Abstraction

Do not create utility functions or shared libraries for code that is only used
once. Abstract when the second use case appears, not before.
