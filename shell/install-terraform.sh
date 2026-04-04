#!/bin/bash
set -euo pipefail

# Install HashiCorp Terraform on Debian/Ubuntu systems.
# Usage: sudo ./install-terraform.sh

if [ "$(id -u)" -ne 0 ]; then
  echo "Error: This script must be run as root (use sudo)."
  exit 1
fi

echo "Installing HashiCorp Terraform..."

# Setup HashiCorp apt repository
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/setup-hashicorp-repo.sh"

# Install terraform
apt-get install -y -qq terraform > /dev/null

# Verify
terraform version

echo "Terraform installation complete."
