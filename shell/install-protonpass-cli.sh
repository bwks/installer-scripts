#!/bin/bash
set -euo pipefail

# Install Proton Pass CLI for the current user with the official installer.
# https://protonpass.github.io/pass-cli/get-started/installation/

echo "Installing Proton Pass CLI..."

# Install to the same user-local directory used by the other CLI installers.
curl -fsSL https://proton.me/download/pass-cli/install.sh \
    | PROTON_PASS_CLI_INSTALL_DIR="$HOME/.local/bin" bash

# Ensure the installed binary is available for verification in this session.
export PATH="$HOME/.local/bin:$PATH"

pass-cli --version
echo "Proton Pass CLI installation complete."
