#!/bin/bash
set -euo pipefail

# Install QEMU/KVM and libvirt on Ubuntu.

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

echo "Installing QEMU/KVM and libvirt..."

as_root apt-get update -qq
as_root apt-get install -y -qq \
  qemu-kvm \
  qemu-utils \
  libvirt-daemon-system \
  libvirt-clients \
  bridge-utils \
  virtinst \
  ovmf \
  > /dev/null

# Enable and start libvirtd
as_root systemctl enable --now libvirtd

# Add the sherpa user to libvirt and kvm groups
as_root usermod -aG libvirt sherpa
as_root usermod -aG kvm sherpa
echo "Added sherpa to libvirt and kvm groups."

# Verify
echo ""
echo "QEMU version:   $(qemu-system-x86_64 --version | head -1)"
echo "libvirtd:       $(virsh version --daemon 2>/dev/null | grep 'Running hypervisor' || echo 'running')"
echo "KVM available:  $([ -e /dev/kvm ] && echo 'yes' || echo 'no (/dev/kvm not found)')"
echo ""
echo "Installation complete."
