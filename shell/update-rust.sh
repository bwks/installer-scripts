#!/bin/bash
set -euo pipefail

# Update the system-wide Rust toolchain via rustup.
# Intended to be run as root by cloud-init on first boot.

if [ "$(id -u)" -ne 0 ]; then
  echo "Error: This script must be run as root."
  exit 1
fi

export RUSTUP_HOME=/usr/local/rustup
export CARGO_HOME=/usr/local/cargo
export PATH="/usr/local/cargo/bin:$PATH"

echo "Updating Rust toolchain..."
rustup update stable

# Verify
rustc --version
cargo --version

echo "Rust update complete."
