#!/bin/bash
set -euo pipefail

# Install 1Password CLI on Ubuntu/Debian via the official APT repository.
# https://www.1password.dev/cli/get-started

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

echo "Installing 1Password CLI..."

# Install tools required to configure the official repository.
as_root apt-get update -qq
as_root apt-get install -y -qq ca-certificates curl gnupg > /dev/null

architecture="$(dpkg --print-architecture)"
key_url="https://downloads.1password.com/linux/keys/1password.asc"
repository_url="https://downloads.1password.com/linux/debian/$architecture"
keyring="/usr/share/keyrings/1password-archive-keyring.gpg"
debsig_policy_dir="/etc/debsig/policies/AC2D62742012EA22"
debsig_keyring_dir="/usr/share/debsig/keyrings/AC2D62742012EA22"

# Add the repository signing key and architecture-specific stable repository.
as_root mkdir -p /usr/share/keyrings /etc/apt/sources.list.d
curl -fsSL "$key_url" | as_root gpg --batch --yes --dearmor --output "$keyring"
echo "deb [arch=$architecture signed-by=$keyring] $repository_url stable main" \
  | as_root tee /etc/apt/sources.list.d/1password.list > /dev/null

# Add 1Password's debsig verification policy and keyring.
as_root mkdir -p "$debsig_policy_dir" "$debsig_keyring_dir"
curl -fsSL https://downloads.1password.com/linux/debian/debsig/1password.pol \
  | as_root tee "$debsig_policy_dir/1password.pol" > /dev/null
curl -fsSL "$key_url" \
  | as_root gpg --batch --yes --dearmor --output "$debsig_keyring_dir/debsig.gpg"

# Install and verify the CLI.
as_root apt-get update -qq
as_root apt-get install -y -qq 1password-cli > /dev/null

op --version
echo "1Password CLI installation complete."
