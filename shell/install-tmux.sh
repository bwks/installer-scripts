#!/bin/bash
set -euo pipefail

# Install tmux terminal multiplexer on Debian/Ubuntu via apt.
# User configuration and plugins are managed separately (for example, with stow).

echo "Installing tmux..."

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

as_root apt-get update -qq
as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq tmux > /dev/null

echo ""
echo "tmux version: $(tmux -V)"
echo ""
echo "Installation complete. Start tmux with: tmux"
