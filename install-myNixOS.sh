#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/Imzaa/myNixOS.git"
REPO_DIR="$HOME/myNixOS"
HOST="myNix"

echo "==> Checking required commands"

if ! command -v git >/dev/null 2>&1; then
  echo "git not found. Installing git temporarily with nix shell..."
  nix shell nixpkgs#git -c bash -c "echo git ready"
fi

echo "==> Cloning or updating repo"

if [ -d "$REPO_DIR/.git" ]; then
  cd "$REPO_DIR"
  git pull
else
  git clone "$REPO_URL" "$REPO_DIR"
  cd "$REPO_DIR"
fi

echo "==> Generating fresh hardware config for this machine"

sudo nixos-generate-config --show-hardware-config > /tmp/hardware.nix

echo "==> Backing up repo hardware.nix"

if [ -f "$REPO_DIR/modules/hosts/myNix/hardware.nix" ]; then
  cp "$REPO_DIR/modules/hosts/myNix/hardware.nix" \
     "$REPO_DIR/modules/hosts/myNix/hardware.nix.bak.$(date +%s)"
fi

echo "==> Installing this machine's hardware config"

cp /tmp/hardware.nix "$REPO_DIR/modules/hosts/myNix/hardware.nix"

echo "==> Rebuilding NixOS"

sudo nixos-rebuild switch --flake "$REPO_DIR#$HOST"

echo "==> Done"
echo
echo "Reboot recommended:"
echo "  sudo reboot"
