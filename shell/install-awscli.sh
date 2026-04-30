#!/bin/bash
set -euo pipefail

# Install the AWS CLI v2 on Linux (x86_64).
# https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

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

echo "Installing AWS CLI v2..."

# Download and extract
tmpdir=$(mktemp -d)
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "$tmpdir/awscliv2.zip"
unzip -q "$tmpdir/awscliv2.zip" -d "$tmpdir"

# Install (or update if already installed)
if command -v aws &> /dev/null; then
  as_root "$tmpdir/aws/install" --update
else
  as_root "$tmpdir/aws/install"
fi

# Cleanup
rm -rf "$tmpdir"

# Verify
aws --version

echo "AWS CLI installation complete."
