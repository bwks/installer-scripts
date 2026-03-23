#!/bin/bash
set -euo pipefail

# Install Python development tools from Astral to /usr/local/bin (system-wide):
#   uv   - fast Python package and project manager
#   ruff - fast Python linter and formatter
#   ty   - fast Python type checker

if [ "$(id -u)" -ne 0 ]; then
  echo "Error: This script must be run as root."
  exit 1
fi

echo "Installing Python dev tools (uv, ruff, ty) to /usr/local/bin..."

UV_INSTALL_DIR=/usr/local/bin UV_NO_MODIFY_PATH=1 \
  curl -LsSf https://astral.sh/uv/install.sh | sh

RUFF_INSTALL_DIR=/usr/local/bin RUFF_NO_MODIFY_PATH=1 \
  curl -LsSf https://astral.sh/ruff/install.sh | sh

TY_INSTALL_DIR=/usr/local/bin TY_NO_MODIFY_PATH=1 \
  curl -LsSf https://astral.sh/ty/install.sh | sh

# Verify
uv --version
ruff --version
ty --version

echo "Python dev tools installation complete."
