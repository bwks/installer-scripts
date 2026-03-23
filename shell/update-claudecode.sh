#!/bin/bash
set -euo pipefail

# Update Claude Code.

export PATH="$HOME/.local/bin:$PATH"

echo "Updating Claude Code..."

claude update

echo "Claude Code update complete."
