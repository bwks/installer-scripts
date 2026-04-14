#!/bin/bash
set -euo pipefail

# Install the Nanos unikernel toolchain (ops) on Linux.
# https://nanos.org / https://ops.city
# Installs the `ops` CLI to $HOME/.ops/bin for the current user.

echo "Installing Nanos toolchain (ops)..."

# Run the official ops installer. It downloads the latest `ops` binary to
# $HOME/.ops/bin and prints PATH instructions for the user's shell.
curl -sSfL https://ops.city/get.sh | sh

# Add $HOME/.ops/bin to PATH for verification in this shell session.
export PATH="$HOME/.ops/bin:$PATH"

# Verify
ops version

echo "Nanos toolchain installation complete."
echo "Ensure \$HOME/.ops/bin is on your PATH (see install output for shell profile instructions)."
