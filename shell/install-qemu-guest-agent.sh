#!/bin/bash
set -euo pipefail

# Install and enable qemu-guest-agent on Ubuntu.

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

echo "Installing qemu-guest-agent..."

as_root apt-get update -qq
as_root apt-get install -y -qq qemu-guest-agent > /dev/null

as_root systemctl enable --now qemu-guest-agent

echo ""
echo "qemu-guest-agent installed and running."
