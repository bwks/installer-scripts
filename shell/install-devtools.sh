#!/bin/bash
set -euo pipefail

# Install general-purpose development tools shared by devbox images.

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

echo "Installing development tools..."

as_root apt-get update -qq
as_root apt-get install -y -qq \
  stow \
  > /dev/null

echo "Development tools installed."
