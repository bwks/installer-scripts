#!/bin/bash
set -euo pipefail

# Add the HashiCorp apt repository and GPG key (idempotent).

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

# Install dependencies
as_root apt-get update -qq
as_root apt-get install -y -qq gnupg software-properties-common curl > /dev/null

# Add HashiCorp GPG key
as_root install -m 0755 -d /usr/share/keyrings
if [ ! -f /usr/share/keyrings/hashicorp-archive-keyring.gpg ]; then
  echo "Adding HashiCorp GPG key..."
  curl -fsSL https://apt.releases.hashicorp.com/gpg | as_root gpg --dearmor --yes -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
fi

# Add HashiCorp repository
if [ ! -f /etc/apt/sources.list.d/hashicorp.list ]; then
  echo "Adding HashiCorp apt repository..."
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    | as_root tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
fi

as_root apt-get update -qq

echo "HashiCorp repository setup complete."
