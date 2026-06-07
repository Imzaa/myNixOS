#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/Imzaa/myNixOS.git}"
HOST="${HOST:-myNix}"
REPO_DIR="${REPO_DIR:-$HOME/myNixOS}"
HARDWARE_PATH="modules/hosts/$HOST/hardware.nix"

echo "==> iNiR / myNixOS installer"
echo "Repo: $REPO_URL"
echo "Host: $HOST"
echo "Repo dir: $REPO_DIR"
echo

if ! command -v git >/dev/null 2>&1; then
  echo "git not found. Installing git temporarily with nix shell..."
  exec nix shell nixpkgs#git -c "$0" "$@"
fi

if [ ! -d "$REPO_DIR/.git" ]; then
  echo "==> Cloning repo..."
  git clone "$REPO_URL" "$REPO_DIR"
fi

cd "$REPO_DIR"

echo "==> Generating hardware config for this machine..."
mkdir -p "modules/hosts/$HOST"

if [ -f "$HARDWARE_PATH" ]; then
  cp "$HARDWARE_PATH" "$HARDWARE_PATH.backup.$(date +%Y%m%d-%H%M%S)"
fi

sudo nixos-generate-config --show-hardware-config > "$HARDWARE_PATH"

echo "==> Hardware config written to:"
echo "$REPO_DIR/$HARDWARE_PATH"
echo

echo "==> Checking flake..."
nix flake check

echo "==> Rebuilding system..."
sudo nixos-rebuild switch --flake ".#$HOST"

echo
echo "==> Done."
echo "If iNiR does not restart automatically, run:"
echo "pkill qs; pkill quickshell; inir run"
