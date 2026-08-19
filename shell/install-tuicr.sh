#!/bin/bash
set -euo pipefail

# Install tuicr (terminal UI for code review) for the current user.
# https://tuicr.dev/

echo "Installing tuicr..."

# Run the official installer non-interactively. It installs the binary to
# $HOME/.local/bin by default.
curl -fsSL https://tuicr.dev/install.sh | TUICR_INSTALL_YES=1 sh

# Ensure the installed binary is available for verification in this session.
export PATH="$HOME/.local/bin:$PATH"

tuicr --version
echo "tuicr installation complete."
