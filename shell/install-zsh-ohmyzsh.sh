#!/bin/bash
set -euo pipefail

# Install zsh and Oh My Zsh for the current user, then set zsh as the
# default login shell.
# https://www.zsh.org
# https://ohmyz.sh

echo "Installing zsh and Oh My Zsh..."

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

# If run through sudo, install/configure Oh My Zsh for the invoking user rather
# than root.
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

# Install zsh and tools required by the Oh My Zsh installer.
as_root apt-get update -qq
as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq zsh curl git > /dev/null

ZSH_PATH="$(command -v zsh)"

# Install Oh My Zsh non-interactively if it is not already installed.
if [ -d "$TARGET_HOME/.oh-my-zsh" ]; then
  echo "Oh My Zsh already installed at $TARGET_HOME/.oh-my-zsh"
else
  echo "Installing Oh My Zsh for $TARGET_USER..."
  tmpinstaller="$(mktemp)"
  curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o "$tmpinstaller"
  chmod 0755 "$tmpinstaller"
  as_target env RUNZSH=no CHSH=no "$tmpinstaller"
  rm -f "$tmpinstaller"
fi

# Ensure ownership is correct when the script was invoked with sudo/root.
if [ "$(id -u)" -eq 0 ] && [ "$TARGET_USER" != "root" ]; then
  if [ -d "$TARGET_HOME/.oh-my-zsh" ]; then
    chown -R "$TARGET_USER:$TARGET_GROUP" "$TARGET_HOME/.oh-my-zsh"
  fi
  if [ -f "$TARGET_HOME/.zshrc" ]; then
    chown "$TARGET_USER:$TARGET_GROUP" "$TARGET_HOME/.zshrc"
  fi
fi

# Set zsh as the default login shell for the target user.
CURRENT_SHELL="$(getent passwd "$TARGET_USER" | cut -d: -f7 || true)"
if [ "$CURRENT_SHELL" = "$ZSH_PATH" ]; then
  echo "zsh is already the default shell for $TARGET_USER"
else
  echo "Setting zsh as the default shell for $TARGET_USER..."
  as_root chsh -s "$ZSH_PATH" "$TARGET_USER"
fi

echo ""
echo "zsh version: $(zsh --version)"
echo "Oh My Zsh installation complete."
echo "Default shell changes take effect after logging out and back in."
