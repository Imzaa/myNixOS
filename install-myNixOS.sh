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

TMP_HW="$(mktemp)"

# Generate to temp first, so failed generation does not destroy hardware.nix
if ! sudo nixos-generate-config --show-hardware-config > "$TMP_HW"; then
  echo "ERROR: nixos-generate-config failed. Existing hardware.nix was not overwritten."
  rm -f "$TMP_HW"
  exit 1
fi

# Wrap normal NixOS hardware config as a flake-parts module.
{
  echo '{ self, inputs, ... }:'
  echo ''
  echo '{'
  echo '  flake.nixosModules.myNixHardware ='
  sed 's/^/    /' "$TMP_HW"
  echo ';'
  echo '}'
} > "$HARDWARE_PATH"

rm -f "$TMP_HW"

echo "==> Hardware config written to:"
echo "$REPO_DIR/$HARDWARE_PATH"
echo

# Nix flakes only see files known to Git.
# hardware.nix can still be ignored/not committed, but it must be force-added locally.
git add -f "$HARDWARE_PATH"

echo "==> Checking flake..."
nix flake check

echo "==> Rebuilding system..."
sudo nixos-rebuild switch --flake ".#$HOST"

echo
echo "==> Done."
echo "If iNiR does not restart automatically, run:"
echo "pkill qs; pkill quickshell; inir run"
