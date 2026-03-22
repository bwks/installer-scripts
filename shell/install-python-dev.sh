#!/bin/bash
set -euo pipefail

# Install Python development tools from Astral:
#   uv   - fast Python package and project manager
#   ruff - fast Python linter and formatter
#   ty   - fast Python type checker

echo "Installing Python dev tools (uv, ruff, ty)..."

curl -LsSf https://astral.sh/uv/install.sh | sh
curl -LsSf https://astral.sh/ruff/install.sh | sh
curl -LsSf https://astral.sh/ty/install.sh | sh

# Verify
export PATH="$HOME/.local/bin:$PATH"
uv --version
ruff --version
ty --version

echo "Python dev tools installation complete."
