#!/bin/bash
set -euo pipefail

# Install Python development tools from Astral to ~/.local/bin (user-level):
#   uv   - fast Python package and project manager
#   ruff - fast Python linter and formatter
#   ty   - fast Python type checker

echo "Installing Python dev tools (uv, ruff, ty) to ~/.local/bin..."

curl -LsSf https://astral.sh/uv/install.sh | sh
curl -LsSf https://astral.sh/ruff/install.sh | sh
curl -LsSf https://astral.sh/ty/install.sh | sh

# Ensure ~/.local/bin is on PATH for this session
export PATH="$HOME/.local/bin:$PATH"

# Verify
uv --version
ruff --version
ty --version

echo "Python dev tools installation complete."
