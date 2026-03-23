#!/bin/bash
set -euo pipefail

# Install Rust toolchain (stable) system-wide via rustup.
# Build dependencies should be installed separately via install-dev-dependencies.sh.

if [ "$(id -u)" -ne 0 ]; then
  echo "Error: This script must be run as root."
  exit 1
fi

export RUSTUP_HOME=/usr/local/rustup
export CARGO_HOME=/usr/local/cargo

echo "Installing Rust toolchain system-wide..."
curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --no-modify-path

# Add cargo bin to system-wide PATH
echo 'export PATH="/usr/local/cargo/bin:$PATH"' > /etc/profile.d/rust.sh
chmod 644 /etc/profile.d/rust.sh

# Verify
export PATH="/usr/local/cargo/bin:$PATH"
rustc --version
cargo --version

echo "Rust installation complete."
