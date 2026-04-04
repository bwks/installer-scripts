#!/bin/bash
set -euo pipefail

# Install the Azure CLI on Ubuntu/Debian via the Microsoft apt repository.
# https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux

if [ "$(id -u)" -ne 0 ]; then
  echo "Error: This script must be run as root."
  exit 1
fi

echo "Installing Azure CLI..."

# Install dependencies
apt-get update -qq
apt-get install -y -qq ca-certificates curl apt-transport-https lsb-release gnupg > /dev/null

# Add Microsoft signing key
mkdir -p /etc/apt/keyrings
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg
chmod a+r /etc/apt/keyrings/microsoft.gpg

# Add Azure CLI repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" \
  > /etc/apt/sources.list.d/azure-cli.list

# Install Azure CLI
apt-get update -qq
apt-get install -y -qq azure-cli > /dev/null

# Verify
az version

echo "Azure CLI installation complete."
