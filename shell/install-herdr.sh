#!/bin/bash
set -euo pipefail

# Install Herdr for the current user with the official installer.
# https://herdr.dev/docs/install/

echo "Installing Herdr..."

curl -fsSL https://herdr.dev/install.sh | sh

# Ensure the installed binary is available for verification in this session.
export PATH="$HOME/.local/bin:$PATH"

herdr --version
echo "Herdr installation complete."
