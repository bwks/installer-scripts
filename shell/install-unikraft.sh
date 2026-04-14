#!/bin/bash
set -euo pipefail

# Install the Unikraft toolchain (kraftkit) on Linux.
# https://unikraft.org/docs/cli
# Installs the `kraft` CLI via the official apt repository.

if [ "$(id -u)" -ne 0 ]; then
  echo "Error: This script must be run as root (use sudo)."
  exit 1
fi

echo "Installing Unikraft toolchain (kraftkit)..."

# Setup apt repository
mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.pkg.kraftkit.sh/gpg.key | gpg --dearmor -o /etc/apt/keyrings/unikraft.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/unikraft.gpg] https://deb.pkg.kraftkit.sh /" | tee /etc/apt/sources.list.d/kraftkit.list > /dev/null

apt-get update -qq
apt-get install -y -qq kraftkit > /dev/null

# Verify
kraft version

echo "Unikraft toolchain installation complete."
