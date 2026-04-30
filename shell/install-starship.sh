#!/bin/bash
set -euo pipefail

# Install Starship prompt for the current user.
# https://starship.rs

INSTALL_DIR="$HOME/.local/bin"

add_starship_init() {
  local file="$1"
  local shell_name="$2"
  local marker="# Starship prompt initialization"
  local init_line="eval \"\$(starship init ${shell_name})\""

  if [ ! -f "$file" ]; then
    touch "$file"
  fi

  if grep -qF "$marker" "$file" || grep -qF "starship init ${shell_name}" "$file"; then
    echo "Starship init already present in $file"
  else
    {
      echo ""
      echo "$marker"
      echo "$init_line"
    } >> "$file"
    echo "Added Starship init to $file"
  fi
}

echo "Installing Starship prompt..."

mkdir -p "$INSTALL_DIR"

# Run the official installer and install the binary for the current user.
curl -fsSL https://starship.rs/install.sh | sh -s -- -b "$INSTALL_DIR" -y

# Ensure ~/.local/bin is on PATH for this session.
export PATH="$INSTALL_DIR:$PATH"

# Configure supported shells idempotently.
add_starship_init "$HOME/.bashrc" "bash"
if command -v zsh &> /dev/null; then
  add_starship_init "$HOME/.zshrc" "zsh"
fi

# Verify installation.
starship --version

echo "Starship installation complete. Restart your shell or source your shell profile to enable the prompt."
