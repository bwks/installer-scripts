#!/bin/bash
set -euo pipefail

# Install pi (Pi Coding Agent) globally via npm.
# https://pi.dev
# Requires Node.js and npm (install first via install-nodejs.sh).

if ! command -v npm &> /dev/null; then
    echo "Error: npm not found. Install Node.js first (e.g. via install-nodejs.sh)."
    exit 1
fi

echo "Installing pi (Pi Coding Agent)..."

# Install globally. Uses sudo if npm's global prefix is not user-writable.
if [ -w "$(npm config get prefix)" ]; then
    npm install -g @mariozechner/pi-coding-agent
else
    sudo npm install -g @mariozechner/pi-coding-agent
fi

# Verify
pi --version || pi --help | head -n 1

echo "pi installation complete."
