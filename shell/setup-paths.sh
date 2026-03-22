#!/bin/bash
set -euo pipefail

# Ensure $HOME/.local/bin is on the PATH for the current user.
# Supports bash and zsh. Idempotent — won't add duplicates.

EXPORT_LINE='export PATH="$HOME/.local/bin:$PATH"'

add_to_file() {
  local file="$1"
  if [ -f "$file" ] && grep -qF '.local/bin' "$file"; then
    echo "Already present in $file, skipping."
  else
    echo "$EXPORT_LINE" >> "$file"
    echo "Added to $file."
  fi
}

# bash
add_to_file "$HOME/.bashrc"

# zsh (if installed)
if command -v zsh &> /dev/null; then
  add_to_file "$HOME/.zshrc"
fi

# Apply to current session
export PATH="$HOME/.local/bin:$PATH"

echo "Done. \$HOME/.local/bin is now on your PATH."
