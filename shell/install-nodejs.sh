#!/bin/bash
set -euo pipefail

# Install Node.js (LTS) and npm on Debian/Ubuntu systems via the official
# NodeSource apt repository.
# https://github.com/nodesource/distributions
# Usage: sudo ./install-nodejs.sh

if [ "$(id -u)" -ne 0 ]; then
  echo "Error: This script must be run as root (use sudo)."
  exit 1
fi

# Node.js major version to install (LTS).
NODE_MAJOR="${NODE_MAJOR:-22}"

echo "Installing Node.js ${NODE_MAJOR}.x (LTS) and npm..."

# Ensure prerequisites are present.
apt-get update -qq
apt-get install -y -qq ca-certificates curl gnupg > /dev/null

# Add the NodeSource GPG key.
mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL "https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key" \
  | gpg --dearmor --yes -o /etc/apt/keyrings/nodesource.gpg
chmod go+r /etc/apt/keyrings/nodesource.gpg

# Add the NodeSource apt repository.
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" \
  > /etc/apt/sources.list.d/nodesource.list

# Install Node.js (bundles npm).
apt-get update -qq
apt-get install -y -qq nodejs > /dev/null

# Verify
node --version
npm --version

echo "Node.js installation complete."
