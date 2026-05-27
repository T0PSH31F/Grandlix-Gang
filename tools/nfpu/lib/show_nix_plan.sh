#!/usr/bin/env bash
set -euo pipefail

# List derivations that will be rebuilt for each machine.
# Adjust MACHINE list as needed.
MACHINES=("luffy" "z0r0")

for m in "${MACHINES[@]}"; do
    echo "🔧  Machine: $m"
    nix build ".#nixosConfigurations.${m}.config.system.build.toplevel" \
        --no-link --dry-run --keep-going \
        | { grep -E 'building|reusing' || true; } \
        | sed -E 's/^(building|reusing)/   • \1/'
    echo ""
 done
