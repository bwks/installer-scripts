#!/bin/bash
set -euo pipefail

# Install and enable qemu-guest-agent on Ubuntu.
# Executed by cloud-init as root.

if [ "$(id -u)" -ne 0 ]; then
  echo "Error: This script must be run as root."
  exit 1
fi

echo "Installing qemu-guest-agent..."

apt-get update -qq
apt-get install -y -qq qemu-guest-agent > /dev/null

systemctl enable --now qemu-guest-agent

echo ""
echo "qemu-guest-agent installed and running."
