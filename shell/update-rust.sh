#!/bin/bash
set -euo pipefail

# Update the Rust toolchain via rustup.

source "$HOME/.cargo/env"

echo "Updating Rust toolchain..."
rustup update stable

# Verify
rustc --version
cargo --version

echo "Rust update complete."
