#!/bin/bash
set -euo pipefail

# Install Codex CLI and its Linux sandbox dependencies.
# https://developers.openai.com/codex

check_bubblewrap() {
    /usr/bin/bwrap \
        --unshare-user \
        --unshare-net \
        --uid 0 \
        --gid 0 \
        --ro-bind / / \
        /bin/true >/dev/null 2>&1
}

if ! command -v apt-get >/dev/null 2>&1; then
    echo "Error: this installer requires an Ubuntu/Debian-based system with apt-get."
    exit 1
fi

echo "Installing Codex Linux sandbox dependencies..."
sudo apt-get update
sudo apt-get install -y apparmor apparmor-profiles bubblewrap

# Ubuntu may restrict unprivileged user namespaces with AppArmor. Load the
# packaged bwrap profile only when the distribution binary cannot create the
# namespaces Codex needs.
if ! check_bubblewrap; then
    BWRAP_PROFILE_SOURCE="/usr/share/apparmor/extra-profiles/bwrap-userns-restrict"
    BWRAP_PROFILE_TARGET="/etc/apparmor.d/bwrap-userns-restrict"

    if [ ! -f "$BWRAP_PROFILE_SOURCE" ]; then
        echo "Error: Bubblewrap cannot create user namespaces and its AppArmor profile was not found."
        exit 1
    fi

    echo "Enabling the Bubblewrap AppArmor profile..."
    sudo install -m 0644 "$BWRAP_PROFILE_SOURCE" "$BWRAP_PROFILE_TARGET"
    sudo apparmor_parser -r "$BWRAP_PROFILE_TARGET"
fi

if ! check_bubblewrap; then
    echo "Error: Bubblewrap cannot create the user and network namespaces Codex requires."
    exit 1
fi

echo "Installing Codex CLI..."

# Set SHELL explicitly so the installer adds ~/.local/bin to Bash's profile
# even when this script is launched from a different login shell.
curl -fsSL https://chatgpt.com/codex/install.sh | SHELL=/bin/bash bash

# Ensure the installed binary is available for verification in this session.
export PATH="$HOME/.local/bin:$PATH"

codex --version
echo "Codex CLI installation complete."
