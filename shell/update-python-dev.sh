#!/bin/bash
set -euo pipefail

# Update Python development tools (uv, ruff, ty).

export PATH="$HOME/.local/bin:$PATH"

echo "Updating Python dev tools (uv, ruff, ty)..."

uv self update
ruff self update
ty self update

echo "Python dev tools update complete."
