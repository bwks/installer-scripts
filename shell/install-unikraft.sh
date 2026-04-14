#!/bin/bash
set -euo pipefail

# Install the Unikraft toolchain (kraftkit) on Linux.
# https://unikraft.org/docs/cli
# Installs the `kraft` CLI to /usr/local/bin.

echo "Installing Unikraft toolchain (kraftkit)..."

# Run the official kraftkit installer. It fetches the latest release and
# installs the `kraft` binary; it uses sudo internally to write to
# /usr/local/bin, so this script does not need to be run as root.
curl --proto '=https' --tlsv1.2 -sSf https://get.kraftkit.sh | sh

# Verify
kraft version

echo "Unikraft toolchain installation complete."
