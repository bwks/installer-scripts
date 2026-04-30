#!/bin/bash
set -euo pipefail

# Install the Azure CLI on Ubuntu/Debian via the Microsoft apt repository.
# https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux

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

echo "Installing Azure CLI..."

# Install dependencies
as_root apt-get update -qq
as_root apt-get install -y -qq ca-certificates curl apt-transport-https lsb-release gnupg > /dev/null

# Add Microsoft signing key
as_root mkdir -p /etc/apt/keyrings
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | as_root gpg --dearmor --yes -o /etc/apt/keyrings/microsoft.gpg
as_root chmod a+r /etc/apt/keyrings/microsoft.gpg

# Add Azure CLI repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" \
  | as_root tee /etc/apt/sources.list.d/azure-cli.list > /dev/null

# Install Azure CLI
as_root apt-get update -qq
as_root apt-get install -y -qq azure-cli > /dev/null

# Verify
az version

echo "Azure CLI installation complete."
