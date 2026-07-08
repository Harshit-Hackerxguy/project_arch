# Troubleshooting

This document describes known problems, diagnostic procedures, and recovery
steps for `project_arch`. It is organized by layer and symptom.

If you encounter a problem not listed here, check the Arch Wiki first. It is
the definitive reference for Arch Linux issues. If you believe you have found
a bug in the configuration, open an issue.

---

## General Diagnostic Procedure

Before looking up a specific symptom, gather information:

```bash
# What is the exact error message?
# Copy it in full — partial error messages lead to wrong diagnoses.

# What command caused the error?
# What was the last thing that worked?

# Check system logs
journalctl -xe --no-pager | tail -50

# Check the state of a specific service
systemctl status <service-name>

# Check what version of a package is installed
pacman -Q <package-name>

# Check if a command is available
which <command-name>
command -v <command-name>
```

---

## Layer 1 Issues

### Pacman fails with "unable to lock database"

**Symptom:**
```
error: failed to init transaction (unable to lock database)
error: could not lock database: File exists
```

**Cause:** A previous pacman operation was interrupted, leaving a lock file.

**Fix:**
```bash
# Verify no pacman process is currently running
ps aux | grep pacman

# If no pacman is running, remove the stale lock
sudo rm /var/lib/pacman/db.lck
```

**Do not remove the lock file if pacman is currently running.**

---

### Pacman fails with "invalid or corrupted package"

**Symptom:**
```
error: failed to commit transaction (invalid or corrupted package (checksum))
```

**Cause:** Partially downloaded package file in the cache.

**Fix:**
```bash
# Clear the package cache
sudo pacman -Sc

# Sync and retry
sudo pacman -Sy
sudo pacman -S <package-name>
```

---

### Pacman fails with "key could not be looked up remotely"

**Symptom:**
```
error: key "XXXXXXXXXXXXXXXX" could not be looked up remotely
```

**Cause:** Expired or missing keyring entries.

**Fix:**
```bash
# Refresh keyring
sudo pacman-key --refresh-keys

# Reinitialize keyring from scratch (if refresh fails)
sudo pacman-key --init
sudo pacman-key --populate archlinux
sudo pacman -Sy archlinux-keyring
```

---

### A service fails to start after `services.sh`

**Symptom:** `systemctl enable` succeeds but the service shows "failed" on boot.

**Diagnostic:**
```bash
# Check the service status
systemctl status <service-name>

# Check journal for the service
journalctl -u <service-name> -n 100 --no-pager
```

**Common causes:**

| Service | Common Failure Reason | Fix |
|---|---|---|
| `NetworkManager` | Conflicting network service | Disable `dhcpcd`: `systemctl disable dhcpcd` |
| `bluetooth` | Bluetooth hardware absent | Expected failure — skip on systems without Bluetooth |
| `pipewire` | User service, not system | Start as user: `systemctl --user enable pipewire` |

---

### Shell environment variables not set after Layer 1

**Symptom:** After running `shell.sh`, `echo $EDITOR` returns blank.

**Cause:** Changes to `~/.bash_profile` only take effect in new login shells.

**Fix:**
```bash
# Re-source the profile in your current shell
source ~/.bash_profile

# Or log out and back in for a clean environment
```

---

### `verify.sh` reports failures after a complete install

**Symptom:** Verification shows `[FAIL]` for items you believe are installed.

**Diagnostic steps:**

1. Check if the failing binary is in your PATH:
   ```bash
   echo "${PATH}"
   which <binary-name>
   ```

2. Check if the package installed correctly:
   ```bash
   pacman -Q <package-name>
   ```

3. If the package is installed but the binary is not found, the binary may
   be in a non-standard location:
   ```bash
   pacman -Ql <package-name> | grep bin
   ```

4. Re-source your profile and retry verification:
   ```bash
   source ~/.bash_profile
   bash install/verify.sh
   ```

---

### `bash install/install.sh` exits early with an error

**Cause:** `set -euo pipefail` causes the script to exit on any error.

**Diagnostic:**
```bash
# Run with debugging enabled to see each command as it executes
bash -x install/install.sh 2>&1 | tee /tmp/install_debug.log

# Then examine the log
cat /tmp/install_debug.log
```

Look for the first `+` line that is followed by a non-zero exit or error message.

---

## Network Issues

### No network connection after installation

**Symptom:** `ping 8.8.8.8` fails.

**Diagnostic:**
```bash
# Check if NetworkManager is running
systemctl status NetworkManager

# List network interfaces
ip link

# Check if any interface has an IP address
ip addr
```

**Fix (if NetworkManager is not running):**
```bash
sudo systemctl start NetworkManager
sudo systemctl enable NetworkManager

# Connect to a network
nmcli device wifi list
nmcli device wifi connect "SSID" password "PASSWORD"
```

---

### DNS resolution fails but ping by IP works

**Symptom:** `ping 8.8.8.8` succeeds but `ping archlinux.org` fails.

**Fix:**
```bash
# Check DNS configuration
cat /etc/resolv.conf

# Set a DNS server manually
echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf

# Or use NetworkManager to set DNS
nmcli con mod <connection-name> ipv4.dns "1.1.1.1 8.8.8.8"
nmcli con up <connection-name>
```

---

## Package Manager Issues

### AUR packages fail to build

**Symptom:** An AUR package (installed via `yay` or `paru`) fails to compile.

**Diagnostic:**
```bash
# Check build dependencies
makepkg --printsrcinfo | grep makedepends

# Build with verbose output
yay -S <package> --noconfirm --buildflags="-v"
```

**Common fixes:**
- Install missing build dependencies manually with `pacman`
- Clear the AUR cache: `yay -Sc`
- Check the AUR package page for known build issues

---

## Permissions Issues

### Script fails with "Permission denied"

**Fix:**
```bash
# Make the script executable
chmod +x install/install.sh

# Or run it explicitly with bash (no execute permission needed)
bash install/install.sh
```

### Sudo password prompt fails

**Symptom:** `sudo` commands in scripts fail with authentication errors.

**Fix:** Run the installer interactively (the scripts prompt for sudo as needed).
Scripts in this repository do not cache or store credentials.

---

## Recovery: Restoring Original Files

Layer 1 creates `.bak` backups of any files it modifies.

| Modified File | Backup |
|---|---|
| `~/.bash_profile` | `~/.bash_profile.bak` |
| `~/.bashrc` | `~/.bashrc.bak` |

To restore:
```bash
cp ~/.bash_profile.bak ~/.bash_profile
cp ~/.bashrc.bak ~/.bashrc
source ~/.bash_profile
```

---

## Getting Further Help

1. **Arch Wiki** — https://wiki.archlinux.org — The best Linux documentation available
2. **Arch Forums** — https://bbs.archlinux.org — Community support
3. **Hyprland Wiki** — https://wiki.hyprland.org — For Layer 2+ issues
4. **Repository Issues** — Open an issue with the full error output and your system information

When reporting an issue, always include:
- The exact error message (full, not paraphrased)
- The command you ran
- The output of `uname -a`
- The output of `pacman -Q | grep <relevant-package>`
