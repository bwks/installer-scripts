#!/bin/bash
set -euo pipefail

# Install development dependencies needed to build and test the Sherpa project.
# The virt_server image already has Docker and libvirt installed.
# This script adds the C build toolchain and headers for Rust FFI crates.

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

echo "Installing Sherpa build dependencies..."

as_root apt-get update -qq
as_root apt-get install -y -qq \
  build-essential \
  pkg-config \
  libssl-dev \
  libvirt-dev \
  genisoimage \
  mtools \
  e2fsprogs \
  unzip \
  > /dev/null

echo "All development dependencies installed."
