#!/bin/bash
set -euo pipefail

# Add the current user ($USER) to the libvirt and kvm groups.
# Run as the target user after install-virt.sh, not via sudo.

TARGET_USER="${USER:-$(id -un)}"

if [ "$TARGET_USER" = "root" ]; then
  echo "Error: run this script as the user to configure, not as root."
  exit 1
fi

if ! command -v sudo &> /dev/null; then
  echo "Error: sudo is required to modify group membership."
  exit 1
fi

for group in libvirt kvm; do
  if ! getent group "$group" > /dev/null; then
    echo "Error: $group group not found. Run install-virt.sh first."
    exit 1
  fi
done

sudo usermod -aG libvirt "$TARGET_USER"
sudo usermod -aG kvm "$TARGET_USER"
echo "Added $TARGET_USER to libvirt and kvm groups. Log out and back in for it to take effect."
