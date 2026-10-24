#!/bin/bash
set -euo pipefail

# Install Proton Pass CLI with the official installer.
# https://protonpass.github.io/pass-cli/get-started/installation/
#
# Usage: install-protonpass-cli.sh [--user | --global]
#   --user    Install to $HOME/.local/bin for the current user (default)
#   --global  Install to /usr/local/bin for all users (requires root or sudo)

SCOPE="user"
case "${1:-}" in
  ""|--user) SCOPE="user" ;;
  --global) SCOPE="global" ;;
  *)
    echo "Usage: $0 [--user | --global]"
    exit 1
    ;;
esac

if [ "$SCOPE" = "global" ]; then
  if [ "$(id -u)" -ne 0 ] && ! command -v sudo &> /dev/null; then
    echo "Error: sudo is required for a global install when running as a non-root user."
    exit 1
  fi
  INSTALL_DIR="/usr/local/bin"
else
  INSTALL_DIR="$HOME/.local/bin"
fi

echo "Installing Proton Pass CLI to $INSTALL_DIR..."

# The official installer uses sudo itself when the directory is not writable.
curl -fsSL https://proton.me/download/pass-cli/install.sh \
    | PROTON_PASS_CLI_INSTALL_DIR="$INSTALL_DIR" bash

# Ensure the installed binary is available for verification in this session.
export PATH="$INSTALL_DIR:$PATH"

pass-cli --version
echo "Proton Pass CLI installation complete."
