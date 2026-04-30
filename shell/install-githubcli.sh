#!/bin/bash
set -euo pipefail

# Install GitHub CLI (gh) via official APT repository
# Requires: Debian/Ubuntu-based system

if [ "$(id -u)" -ne 0 ] && ! command -v sudo &> /dev/null; then
  echo "Error: sudo is required when running as a non-root user."
  exit 1
fi

as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

echo "Installing GitHub CLI..."

# Install wget if not present
if ! command -v wget &> /dev/null; then
    echo "wget not found, installing..."
    as_root apt-get update
    as_root apt-get install -y wget
fi

# Set up the GitHub CLI APT repository keyring
echo "Adding GitHub CLI GPG key..."
as_root mkdir -p -m 755 /etc/apt/keyrings
tmpkey=$(mktemp)
wget -nv -O "$tmpkey" https://cli.github.com/packages/githubcli-archive-keyring.gpg
as_root tee /etc/apt/keyrings/githubcli-archive-keyring.gpg < "$tmpkey" > /dev/null
as_root chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
rm -f "$tmpkey"

# Add the GitHub CLI APT repository
echo "Adding GitHub CLI APT repository..."
as_root mkdir -p -m 755 /etc/apt/sources.list.d
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | as_root tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# Install GitHub CLI
echo "Updating package list and installing gh..."
as_root apt-get update
as_root apt-get install -y gh

echo "GitHub CLI installed successfully"
gh --version
