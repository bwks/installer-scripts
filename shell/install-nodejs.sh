#!/bin/bash
set -euo pipefail

# Install NVM and Node.js (latest LTS by default) for the current user.
# https://github.com/nvm-sh/nvm
# Usage: ./install-nodejs.sh
# Optional env vars:
#   NVM_VERSION=v0.40.3
#   NODE_VERSION='lts/*'

if [ "$(id -u)" -eq 0 ] || [ -n "${SUDO_USER:-}" ]; then
  echo "Error: This script installs NVM for the current user and must not be run as root or with sudo."
  exit 1
fi

if ! command -v curl > /dev/null 2>&1; then
  echo "Error: curl is required. Install curl first, then rerun this script."
  exit 1
fi

NVM_VERSION="${NVM_VERSION:-v0.40.3}"
NODE_VERSION="${NODE_VERSION:-lts/*}"
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

echo "Installing/updating NVM ${NVM_VERSION}..."
curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh" | bash

if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  echo "Error: NVM installation did not create $NVM_DIR/nvm.sh."
  exit 1
fi

# Load NVM for this shell so Node.js can be installed and verified immediately.
# shellcheck source=/dev/null
. "$NVM_DIR/nvm.sh"

echo "Installing Node.js ${NODE_VERSION} via NVM..."
nvm install "$NODE_VERSION"

INSTALLED_VERSION="$(nvm version "$NODE_VERSION")"
if [ "$INSTALLED_VERSION" = "N/A" ]; then
  echo "Error: Node.js version '$NODE_VERSION' was not installed successfully."
  exit 1
fi

nvm alias default "$INSTALLED_VERSION" > /dev/null
nvm use default > /dev/null

# Verify
nvm --version
node --version
npm --version

echo "Node.js installation complete. Restart your shell or source your profile to use node/npm in new sessions."
