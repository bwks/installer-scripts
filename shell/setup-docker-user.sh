#!/bin/bash
set -euo pipefail

# Add the current user ($USER) to the docker group.
# Run as the target user after install-docker.sh, not via sudo.

TARGET_USER="${USER:-$(id -un)}"

if [ "$TARGET_USER" = "root" ]; then
  echo "Error: run this script as the user to configure, not as root."
  exit 1
fi

if ! command -v sudo &> /dev/null; then
  echo "Error: sudo is required to modify group membership."
  exit 1
fi

if ! getent group docker > /dev/null; then
  echo "Error: docker group not found. Run install-docker.sh first."
  exit 1
fi

sudo usermod -aG docker "$TARGET_USER"
echo "Added $TARGET_USER to docker group. Log out and back in for it to take effect."
