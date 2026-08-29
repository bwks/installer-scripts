#!/bin/bash
set -euo pipefail

# Install mise for the current user and configure shell activation.
# https://mise.jdx.dev/installing-mise.html

INSTALL_DIR="$HOME/.local/bin"

add_mise_activation() {
  local file="$1"
  local shell_name="$2"
  local marker="# mise activation"
  local activation_line="eval \"\$(mise activate ${shell_name})\""

  mkdir -p "$(dirname "$file")"
  touch "$file"

  if grep -qF "mise activate ${shell_name}" "$file"; then
    echo "mise activation already present in $file"
  else
    {
      echo ""
      echo "$marker"
      echo "$activation_line"
    } >> "$file"
    echo "Added mise activation to $file"
  fi
}

echo "Installing mise..."

mkdir -p "$INSTALL_DIR"

# Run the official installer. MISE_INSTALL_PATH makes the destination explicit.
curl -fsSL https://mise.run | MISE_INSTALL_PATH="$INSTALL_DIR/mise" sh

# Make mise available for verification in this shell session.
export PATH="$INSTALL_DIR:$PATH"

add_mise_activation "$HOME/.bashrc" "bash"
if command -v zsh &> /dev/null; then
  add_mise_activation "${ZDOTDIR:-$HOME}/.zshrc" "zsh"
fi

mise --version

echo "mise installation complete. Restart your shell or source your shell profile to activate it."
