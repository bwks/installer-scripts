#!/bin/bash
set -euo pipefail

# Install Claude Code system-wide via the native installer.
# https://code.claude.com/docs/en/getting-started

if [ "$(id -u)" -ne 0 ]; then
  echo "Error: This script must be run as root."
  exit 1
fi

echo "Installing Claude Code..."

curl -fsSL https://claude.ai/install.sh | bash

# Move into /usr/local/bin so all users can access it
if [ -f "$HOME/.claude/local/claude" ] && [ ! -f /usr/local/bin/claude ]; then
  mv "$HOME/.claude/local/claude" /usr/local/bin/claude
  echo "Moved claude to /usr/local/bin/claude"
fi

echo "Claude Code installed successfully"
claude --version
