#!/bin/bash
set -euo pipefail

# Install the Nanos unikernel toolchain (ops) on Linux.
# https://nanos.org / https://ops.city
#
# Usage: install-nanos.sh [--user | --global]
#   --user    Install to $HOME/.ops/bin for the current user (default)
#   --global  Install to /usr/local/bin for all users (requires root or sudo)
#
# Either way, ops keeps its per-user images and kernels in $HOME/.ops.

SCOPE="user"
case "${1:-}" in
  ""|--user) SCOPE="user" ;;
  --global) SCOPE="global" ;;
  *)
    echo "Usage: $0 [--user | --global]"
    exit 1
    ;;
esac

echo "Installing Nanos toolchain (ops)..."

if [ "$SCOPE" = "user" ]; then
  # Run the official ops installer. It downloads the latest `ops` binary to
  # $HOME/.ops/bin and prints PATH instructions for the user's shell.
  curl -sSfL https://ops.city/get.sh | sh

  # Add $HOME/.ops/bin to PATH for verification in this shell session.
  export PATH="$HOME/.ops/bin:$PATH"

  ops version

  echo "Nanos toolchain installation complete."
  echo "Ensure \$HOME/.ops/bin is on your PATH (see install output for shell profile instructions)."
  exit 0
fi

if [ "$(id -u)" -ne 0 ] && ! command -v sudo &> /dev/null; then
  echo "Error: sudo is required for a global install when running as a non-root user."
  exit 1
fi

as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

# The official installer only supports $HOME and edits shell profiles, so fetch
# the same release binary and completion it uses and install them system-wide.
case "$(uname -m)" in
  x86_64) BINARY_URL="https://storage.googleapis.com/cli/linux/ops" ;;
  aarch64|arm64) BINARY_URL="https://storage.googleapis.com/cli/linux/aarch64/ops" ;;
  *)
    echo "Error: unsupported architecture $(uname -m)."
    exit 1
    ;;
esac
COMPLETION_URL="https://raw.githubusercontent.com/nanovms/ops/master/bash_completion.sh"

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

curl -fsSL "$BINARY_URL" -o "$TMP_DIR/ops"
curl -fsSL "$COMPLETION_URL" -o "$TMP_DIR/ops-completion"

as_root install -m 0755 "$TMP_DIR/ops" /usr/local/bin/ops
as_root install -m 0755 -d /usr/share/bash-completion/completions
as_root install -m 0644 "$TMP_DIR/ops-completion" /usr/share/bash-completion/completions/ops

/usr/local/bin/ops version

echo "Nanos toolchain installation complete."
