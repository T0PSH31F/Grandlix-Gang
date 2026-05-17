#!/usr/bin/env bash
# Deploy diff tool for NFP

set -e

MACHINE=$1
if [ -z "$MACHINE" ]; then
  echo "Usage: $0 <machine>"
  exit 1
fi

echo "Building current system configuration for $MACHINE..."
NEW_SYSTEM=$(nix build .#nixosConfigurations.$MACHINE.config.system.build.toplevel --print-out-paths --no-link)

if [ -z "$NEW_SYSTEM" ]; then
  echo "Failed to build system."
  exit 1
fi

echo "Comparing with currently running system..."
nvd diff /run/current-system $NEW_SYSTEM
