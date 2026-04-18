#!/bin/bash
set -euo pipefail

# Ensure user-local bin directories are on PATH for the current user.
# Supports bash and zsh. Idempotent — won't add duplicates.

PATH_DIRS=(
  "$HOME/.local/bin"
  "$HOME/.opencode/bin"
)

add_to_file() {
  local file="$1"
  local dir="$2"
  local marker="# PATH: ${dir/#$HOME/\$HOME}"
  if [ -f "$file" ] && grep -qF "$marker" "$file"; then
    echo "Already present in $file: $dir"
  else
    {
      echo "$marker"
      echo "export PATH=\"${dir/#$HOME/\$HOME}:\$PATH\""
    } >> "$file"
    echo "Added to $file: $dir"
  fi
}

for dir in "${PATH_DIRS[@]}"; do
  add_to_file "$HOME/.bashrc" "$dir"
  if command -v zsh &> /dev/null; then
    add_to_file "$HOME/.zshrc" "$dir"
  fi
  export PATH="$dir:$PATH"
done

echo "Done. PATH updated with: ${PATH_DIRS[*]}"
