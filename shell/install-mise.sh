#!/bin/bash
set -euo pipefail

# Install mise and configure shell activation.
# https://mise.jdx.dev/installing-mise.html
#
# Usage: install-mise.sh [--user | --global]
#   --user    Install to $HOME/.local/bin and activate in the current user's
#             shell rc files (default)
#   --global  Install to /usr/local/bin and activate for all users through
#             /etc/profile.d, /etc/bash.bashrc and /etc/zsh/zshrc (requires
#             root or sudo). Each user's tools still install under their home.

SCOPE="user"
case "${1:-}" in
  ""|--user) SCOPE="user" ;;
  --global) SCOPE="global" ;;
  *)
    echo "Usage: $0 [--user | --global]"
    exit 1
    ;;
esac

if [ "$SCOPE" = "global" ]; then
  if [ "$(id -u)" -ne 0 ] && ! command -v sudo &> /dev/null; then
    echo "Error: sudo is required for a global install when running as a non-root user."
    exit 1
  fi
  INSTALL_DIR="/usr/local/bin"
else
  INSTALL_DIR="$HOME/.local/bin"
fi

as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

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

add_global_activation() {
  # Login shells (including non-interactive ones) get shims; interactive
  # shells get full activation from their system-wide rc files.
  as_root tee /etc/profile.d/mise.sh > /dev/null <<'EOF'
# mise activation (shims) for login shells
if [ -n "${BASH_VERSION:-}" ] && [ -x /usr/local/bin/mise ]; then
  eval "$(/usr/local/bin/mise activate bash --shims)"
fi
EOF
  as_root chmod 0644 /etc/profile.d/mise.sh
  echo "Added mise shim activation to /etc/profile.d/mise.sh"

  if ! grep -qF "mise activate bash" /etc/bash.bashrc 2>/dev/null; then
    printf '\n# mise activation\neval "$(/usr/local/bin/mise activate bash)"\n' \
      | as_root tee -a /etc/bash.bashrc > /dev/null
    echo "Added mise activation to /etc/bash.bashrc"
  else
    echo "mise activation already present in /etc/bash.bashrc"
  fi

  if [ -d /etc/zsh ] && ! grep -qF "mise activate zsh" /etc/zsh/zshrc 2>/dev/null; then
    printf '\n# mise activation\neval "$(/usr/local/bin/mise activate zsh)"\n' \
      | as_root tee -a /etc/zsh/zshrc > /dev/null
    echo "Added mise activation to /etc/zsh/zshrc"
  fi
}

echo "Installing mise to $INSTALL_DIR..."

if [ "$SCOPE" = "global" ]; then
  # Download as the invoking user, then install the binary as root.
  TMP_DIR=$(mktemp -d)
  trap 'rm -rf "$TMP_DIR"' EXIT
  curl -fsSL https://mise.run | MISE_INSTALL_PATH="$TMP_DIR/mise" sh
  as_root install -m 0755 "$TMP_DIR/mise" "$INSTALL_DIR/mise"
  add_global_activation
else
  mkdir -p "$INSTALL_DIR"

  # Run the official installer. MISE_INSTALL_PATH makes the destination explicit.
  curl -fsSL https://mise.run | MISE_INSTALL_PATH="$INSTALL_DIR/mise" sh

  add_mise_activation "$HOME/.bashrc" "bash"
  if command -v zsh &> /dev/null; then
    add_mise_activation "${ZDOTDIR:-$HOME}/.zshrc" "zsh"
  fi
fi

# Make mise available for verification in this shell session.
export PATH="$INSTALL_DIR:$PATH"

mise --version

echo "mise installation complete. Restart your shell or source your shell profile to activate it."
