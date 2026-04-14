#!/bin/bash
set -euo pipefail

# Install opencode (AI coding agent) for the current user.
# https://opencode.ai

echo "Installing opencode..."

# Run the official installer. Installs the `opencode` binary to
# $HOME/.opencode/bin and prints PATH instructions for the user's shell.
curl -fsSL https://opencode.ai/install | bash

# Add $HOME/.opencode/bin to PATH for verification in this shell session.
export PATH="$HOME/.opencode/bin:$PATH"

# Verify
opencode --version

echo "opencode installation complete."
echo "Ensure \$HOME/.opencode/bin is on your PATH (see install output for shell profile instructions)."
