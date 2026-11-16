#!/bin/bash
set -euo pipefail

# Install bash and Oh My Bash for the current user, then set bash as the
# default login shell.
# https://www.gnu.org/software/bash/
# https://ohmybash.github.io

echo "Installing bash and Oh My Bash..."

if ! command -v apt-get &> /dev/null; then
  echo "Error: apt-get not found. This script targets Debian/Ubuntu-based systems."
  exit 1
fi

if [ "$(id -u)" -ne 0 ] && ! command -v sudo &> /dev/null; then
  echo "Error: sudo is required when running as a non-root user."
  exit 1
fi

as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

# If run through sudo, install/configure Oh My Bash for the invoking user
# rather than root.
TARGET_USER="${SUDO_USER:-$(id -un)}"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6 || true)"
if [ -z "$TARGET_HOME" ]; then
  TARGET_HOME="$HOME"
fi
TARGET_GROUP="$(id -gn "$TARGET_USER")"

as_target() {
  if [ "$(id -u)" -eq 0 ] && [ "$TARGET_USER" != "root" ]; then
    if command -v runuser &> /dev/null; then
      runuser -u "$TARGET_USER" -- env HOME="$TARGET_HOME" USER="$TARGET_USER" LOGNAME="$TARGET_USER" "$@"
    elif command -v sudo &> /dev/null; then
      sudo -H -u "$TARGET_USER" env HOME="$TARGET_HOME" USER="$TARGET_USER" LOGNAME="$TARGET_USER" "$@"
    else
      "$@"
    fi
  else
    env HOME="$TARGET_HOME" USER="$TARGET_USER" LOGNAME="$TARGET_USER" "$@"
  fi
}

# Install bash and tools required by the Oh My Bash installer.
as_root apt-get update -qq
as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq bash curl git > /dev/null

BASH_PATH="$(command -v bash)"

# Install Oh My Bash non-interactively if it is not already installed.
# Note: the installer backs up an existing ~/.bashrc to
# ~/.bashrc.omb-backup-<timestamp> and replaces it with the Oh My Bash template.
if [ -d "$TARGET_HOME/.oh-my-bash" ]; then
  echo "Oh My Bash already installed at $TARGET_HOME/.oh-my-bash"
else
  echo "Installing Oh My Bash for $TARGET_USER..."
  tmpinstaller="$(mktemp)"
  curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -o "$tmpinstaller"
  chmod 0755 "$tmpinstaller"
  as_target bash "$tmpinstaller" --unattended
  rm -f "$tmpinstaller"
fi

# Ensure ownership is correct when the script was invoked with sudo/root.
if [ "$(id -u)" -eq 0 ] && [ "$TARGET_USER" != "root" ]; then
  if [ -d "$TARGET_HOME/.oh-my-bash" ]; then
    chown -R "$TARGET_USER:$TARGET_GROUP" "$TARGET_HOME/.oh-my-bash"
  fi
  for f in "$TARGET_HOME"/.bashrc "$TARGET_HOME"/.bashrc.omb-backup-*; do
    if [ -f "$f" ]; then
      chown "$TARGET_USER:$TARGET_GROUP" "$f"
    fi
  done
fi

# Set bash as the default login shell for the target user.
CURRENT_SHELL="$(getent passwd "$TARGET_USER" | cut -d: -f7 || true)"
if [ "$CURRENT_SHELL" = "$BASH_PATH" ]; then
  echo "bash is already the default shell for $TARGET_USER"
else
  echo "Setting bash as the default shell for $TARGET_USER..."
  as_root chsh -s "$BASH_PATH" "$TARGET_USER"
fi

echo ""
echo "bash version: $(bash --version | head -n 1)"
echo "Oh My Bash installation complete."
echo "Any previous ~/.bashrc was backed up to ~/.bashrc.omb-backup-<timestamp>."
echo "Default shell changes take effect after logging out and back in."
