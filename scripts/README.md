# scripts/

This directory contains utility and maintenance scripts for `project_arch`.

These are scripts that do not belong to any single configuration layer — they
serve the repository as a whole. Examples include tools for backing up
configuration, syncing dotfiles, checking for system updates, or validating
the repository state.

---

## Distinction from `install/`

| `install/` | `scripts/` |
|---|---|
| Runs once on a fresh system | Runs repeatedly during normal use |
| Configures the OS | Maintains and operates the system |
| Part of the installation lifecycle | Part of the daily-use lifecycle |

---

## Planned Scripts

The following scripts will be added in later layers:

| Script | Purpose |
|---|---|
| `backup.sh` | Back up active configuration to a timestamped archive |
| `diff.sh` | Show differences between repository config and the live system |
| `sync.sh` | Apply repository config to the live system (idempotent) |
| `update.sh` | Update packages defined across all layers |
| `lint.sh` | Run shellcheck and markdownlint across all files |

---

## Standards for Scripts in This Directory

- Every script must begin with a standard header comment block (see `docs/conventions.md`)
- Scripts must be idempotent — running them twice must produce the same result
- Scripts must not silently fail — use `set -euo pipefail`
- All output must use consistent formatting (prefixed with `[script-name]`)
