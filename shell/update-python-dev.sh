#!/bin/bash
set -euo pipefail

# Update Python development tools (uv, ruff, ty) in /usr/local/bin.
# Intended to be run as root by cloud-init on first boot.

if [ "$(id -u)" -ne 0 ]; then
  echo "Error: This script must be run as root."
  exit 1
fi

echo "Updating Python dev tools (uv, ruff, ty)..."

uv self update
ruff self update
ty self update

echo "Python dev tools update complete."
