#!/bin/bash
set -euo pipefail

# Install Zig for the current user from the official Zig tarball.
# https://ziglang.org/download/
# Usage: ./install-zig.sh
# Optional env vars:
#   ZIG_VERSION=0.16.0

if [ "$(id -u)" -eq 0 ] || [ -n "${SUDO_USER:-}" ]; then
  echo "Error: This script installs Zig for the current user and must not be run as root or with sudo."
  exit 1
fi

for cmd in curl tar python3 sha256sum; do
  if ! command -v "$cmd" > /dev/null 2>&1; then
    echo "Error: $cmd is required. Install $cmd first, then rerun this script."
    exit 1
  fi
done

case "$(uname -s)" in
  Linux)
    os="linux"
    ;;
  *)
    echo "Error: This script only supports Linux."
    exit 1
    ;;
esac

case "$(uname -m)" in
  x86_64 | amd64)
    arch="x86_64"
    ;;
  aarch64 | arm64)
    arch="aarch64"
    ;;
  *)
    echo "Error: Unsupported architecture: $(uname -m)"
    exit 1
    ;;
esac

INSTALL_ROOT="${INSTALL_ROOT:-$HOME/.local/opt}"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
DOWNLOAD_INDEX_URL="https://ziglang.org/download/index.json"

tmpdir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmpdir"
}
trap cleanup EXIT

echo "Resolving Zig download..."
index_file="$tmpdir/index.json"
curl -fsSL "$DOWNLOAD_INDEX_URL" -o "$index_file"

download_info="$(
  python3 - "$index_file" "$os" "$arch" "${ZIG_VERSION:-}" << 'PY'
import json
import sys

index_path, os_name, arch, requested_version = sys.argv[1:]
with open(index_path, encoding="utf-8") as file:
    index = json.load(file)

versions = [requested_version] if requested_version else [
    version for version in index.keys() if version != "master"
]

for version in versions:
    release = index.get(version)
    if not release:
        continue

    target = f"{arch}-{os_name}"
    artifact = release.get(target)
    if not artifact:
        continue

    tarball = artifact.get("tarball")
    shasum = artifact.get("shasum", "")
    if tarball:
        print(version)
        print(tarball)
        print(shasum)
        sys.exit(0)

if requested_version:
    print(
        f"Error: Zig {requested_version} is not available for {arch}-{os_name}.",
        file=sys.stderr,
    )
else:
    print(f"Error: No stable Zig release found for {arch}-{os_name}.", file=sys.stderr)
sys.exit(1)
PY
)"

zig_version="$(printf '%s\n' "$download_info" | sed -n '1p')"
tarball_url="$(printf '%s\n' "$download_info" | sed -n '2p')"
expected_shasum="$(printf '%s\n' "$download_info" | sed -n '3p')"

echo "Installing Zig ${zig_version}..."

archive="$tmpdir/zig.tar.xz"
curl -fsSL "$tarball_url" -o "$archive"

if [ -n "$expected_shasum" ]; then
  actual_shasum="$(sha256sum "$archive" | awk '{print $1}')"
  if [ "$actual_shasum" != "$expected_shasum" ]; then
    echo "Error: checksum verification failed for Zig ${zig_version}."
    exit 1
  fi
fi

extract_dir="$tmpdir/extract"
mkdir -p "$extract_dir"
tar -xJf "$archive" -C "$extract_dir"

extracted_zig_dir="$(find "$extract_dir" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
if [ -z "$extracted_zig_dir" ] || [ ! -x "$extracted_zig_dir/zig" ]; then
  echo "Error: Zig archive did not contain an executable zig binary."
  exit 1
fi

mkdir -p "$INSTALL_ROOT" "$BIN_DIR"
versioned_dir="$INSTALL_ROOT/zig-$zig_version"
rm -rf "$versioned_dir"
mv "$extracted_zig_dir" "$versioned_dir"

ln -sfn "$versioned_dir" "$INSTALL_ROOT/zig-current"
ln -sfn "$INSTALL_ROOT/zig-current/zig" "$BIN_DIR/zig"

export PATH="$BIN_DIR:$PATH"

# Verify
zig version

echo "Zig installation complete. Ensure $BIN_DIR is on PATH, or run shell/setup-paths.sh."
