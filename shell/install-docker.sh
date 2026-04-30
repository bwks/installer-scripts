#!/bin/bash
set -euo pipefail

# Install Docker Engine on Ubuntu via the official Docker apt repository.

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

echo "Installing Docker Engine..."

# Install dependencies
as_root apt-get update -qq
as_root apt-get install -y -qq ca-certificates curl > /dev/null

# Add Docker GPG key
as_root install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | as_root tee /etc/apt/keyrings/docker.asc > /dev/null
as_root chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | as_root tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
as_root apt-get update -qq
as_root apt-get install -y -qq \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin \
  > /dev/null

# Enable and start Docker
as_root systemctl enable --now docker

# Add the sherpa user to the docker group
as_root usermod -aG docker sherpa
echo "Added sherpa to docker group."

# Verify
echo ""
echo "Docker version: $(docker --version)"
echo ""
echo "Installation complete."
