#!/bin/bash
set -euo pipefail

# Install Claude Code for the current user.
# https://code.claude.com/docs/en/getting-started

echo "Installing Claude Code..."

curl -fsSL https://claude.ai/install.sh | bash

# Ensure ~/.local/bin is on PATH for this session
export PATH="$HOME/.local/bin:$PATH"

echo "Claude Code installed successfully."
claude --version
