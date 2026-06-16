#!/bin/bash
set -euo pipefail

# Install Perl on Debian/Ubuntu via apt.
# Installs the perl interpreter, core docs, and cpanminus for installing CPAN modules.

echo "Installing Perl..."

if ! command -v apt-get &> /dev/null; then
  echo "Error: apt-get not found. This script targets Debian/Ubuntu-based systems."
  exit 1
fi

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

as_root apt-get update -qq
as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq perl perl-doc cpanminus > /dev/null

echo ""
echo "perl version: $(perl -e 'print $^V')"
echo "cpanm version: $(cpanm --version 2>/dev/null | head -n1)"
echo ""
echo "Installation complete. Install CPAN modules with: cpanm <Module::Name>"
