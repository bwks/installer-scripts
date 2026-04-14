#!/bin/bash
set -euo pipefail

# Install common cargo-based developer tools for the current user.
# Requires cargo (install Rust first via install-rust.sh).

CARGO_TOOLS=(
    "cargo-nextest"
    "cargo-llvm-cov"
)

echo "Installing cargo tools..."

for tool in "${CARGO_TOOLS[@]}"; do
    echo "==> $tool"
    cargo install --locked "$tool"
done

echo "Cargo tools installation complete."
