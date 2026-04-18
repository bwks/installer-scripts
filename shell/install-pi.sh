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

# Install into the user-local prefix (~/.local) so it works without sudo.
# The binary lands in ~/.local/bin which should be on PATH.
npm install -g --prefix "$HOME/.local" @mariozechner/pi-coding-agent

# Verify
pi --version || pi --help | head -n 1

echo "pi installation complete."
