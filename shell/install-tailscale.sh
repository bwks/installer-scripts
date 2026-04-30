#!/bin/bash
set -euo pipefail

# Install Tailscale on Ubuntu/Debian via the official Tailscale apt repository.
# Executed by cloud-init as root.

if [ "$(id -u)" -ne 0 ]; then
  echo "Error: This script must be run as root."
  exit 1
fi

if [ ! -r /etc/os-release ]; then
  echo "Error: /etc/os-release not found. This script supports Ubuntu/Debian-based systems."
  exit 1
fi

. /etc/os-release

case "${ID:-}" in
  ubuntu|debian)
    distro="$ID"
    ;;
  *)
    echo "Error: unsupported distribution '${ID:-unknown}'. This script supports Ubuntu and Debian."
    exit 1
    ;;
esac

if [ -z "${VERSION_CODENAME:-}" ]; then
  echo "Error: VERSION_CODENAME not found in /etc/os-release."
  exit 1
fi

echo "Installing Tailscale..."

# Install dependencies
apt-get update -qq
apt-get install -y -qq ca-certificates curl gnupg > /dev/null

# Add Tailscale GPG key and apt repository
install -m 0755 -d /usr/share/keyrings
curl -fsSL "https://pkgs.tailscale.com/stable/${distro}/${VERSION_CODENAME}.noarmor.gpg" \
  -o /usr/share/keyrings/tailscale-archive-keyring.gpg
chmod a+r /usr/share/keyrings/tailscale-archive-keyring.gpg

curl -fsSL "https://pkgs.tailscale.com/stable/${distro}/${VERSION_CODENAME}.tailscale-keyring.list" \
  -o /etc/apt/sources.list.d/tailscale.list

# Install Tailscale
apt-get update -qq
apt-get install -y -qq tailscale > /dev/null

# Enable and start the Tailscale daemon
systemctl enable --now tailscaled

echo ""
echo "Tailscale version: $(tailscale version | head -n 1)"
echo ""
echo "Installation complete. To authenticate and connect this machine, run:"
echo "  sudo tailscale up"
