#!/bin/bash
set -euo pipefail

# Add the HashiCorp apt repository and GPG key (idempotent).
# Usage: sudo ./setup-hashicorp-repo.sh

if [ "$(id -u)" -ne 0 ]; then
  echo "Error: This script must be run as root (use sudo)."
  exit 1
fi

# Install dependencies
apt-get update -qq
apt-get install -y -qq gnupg software-properties-common curl > /dev/null

# Add HashiCorp GPG key
if [ ! -f /usr/share/keyrings/hashicorp-archive-keyring.gpg ]; then
  echo "Adding HashiCorp GPG key..."
  curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
fi

# Add HashiCorp repository
if [ ! -f /etc/apt/sources.list.d/hashicorp.list ]; then
  echo "Adding HashiCorp apt repository..."
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/hashicorp.list
fi

apt-get update -qq

echo "HashiCorp repository setup complete."
