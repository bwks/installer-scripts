#!/bin/bash
set -euo pipefail

# Install Rust toolchain (stable) for the current user via rustup.
# Build dependencies should be installed separately via install-dev-dependencies.sh.

echo "Installing Rust toolchain..."
curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable

# Source cargo env for this session
source "$HOME/.cargo/env"

# Verify
rustc --version
cargo --version

echo "Rust installation complete."
