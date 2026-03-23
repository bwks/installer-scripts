#!/bin/bash
set -euo pipefail

# Update Claude Code in /usr/local/bin.
# Intended to be run as root by cloud-init on first boot.

if [ "$(id -u)" -ne 0 ]; then
  echo "Error: This script must be run as root."
  exit 1
fi

echo "Updating Claude Code..."

claude update

echo "Claude Code update complete."
