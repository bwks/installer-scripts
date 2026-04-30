#!/bin/bash
set -euo pipefail

# Install the Unikraft toolchain (kraftkit) on Linux.
# https://unikraft.org/docs/cli
# Installs the `kraft` CLI via the official apt repository.

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

echo "Installing Unikraft toolchain (kraftkit)..."

# Setup apt repository
as_root mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.pkg.kraftkit.sh/gpg.key | as_root gpg --dearmor --yes -o /etc/apt/keyrings/unikraft.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/unikraft.gpg] https://deb.pkg.kraftkit.sh /" | as_root tee /etc/apt/sources.list.d/kraftkit.list > /dev/null

as_root apt-get update -qq
as_root apt-get install -y -qq kraftkit > /dev/null

# Verify
kraft version

echo "Unikraft toolchain installation complete."
