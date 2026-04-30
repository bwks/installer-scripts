#!/bin/bash
set -euo pipefail

# Install HashiCorp Packer on Debian/Ubuntu systems.

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

echo "Installing HashiCorp Packer..."

# Setup HashiCorp apt repository
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/setup-hashicorp-repo.sh"

# Install packer
as_root apt-get install -y -qq packer > /dev/null

# Verify
PACKER_VERSION=$(packer version)
echo "Packer installed successfully: ${PACKER_VERSION}"
