#!/bin/bash
set -euo pipefail

# Install Tailscale on Ubuntu/Debian via the official Tailscale apt repository.

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
as_root apt-get update -qq
as_root apt-get install -y -qq ca-certificates curl gnupg > /dev/null

# Add Tailscale GPG key and apt repository
as_root install -m 0755 -d /usr/share/keyrings
curl -fsSL "https://pkgs.tailscale.com/stable/${distro}/${VERSION_CODENAME}.noarmor.gpg" \
  | as_root tee /usr/share/keyrings/tailscale-archive-keyring.gpg > /dev/null
as_root chmod a+r /usr/share/keyrings/tailscale-archive-keyring.gpg

curl -fsSL "https://pkgs.tailscale.com/stable/${distro}/${VERSION_CODENAME}.tailscale-keyring.list" \
  | as_root tee /etc/apt/sources.list.d/tailscale.list > /dev/null

# Install Tailscale
as_root apt-get update -qq
as_root apt-get install -y -qq tailscale > /dev/null

# Enable and start the Tailscale daemon
as_root systemctl enable --now tailscaled

echo ""
echo "Tailscale version: $(tailscale version | head -n 1)"
echo ""
echo "Installation complete. To authenticate and connect this machine, run:"
echo "  sudo tailscale up"
