#!/usr/bin/env bash
set -euo pipefail

# Forecast binary cache hits for upcoming NFP update.
# Uses nix-weather if installed; otherwise falls back to a simple local cache check.
#
# Usage: forecast_cache.sh [machine_name]
#   machine_name: Name of the NixOS configuration to forecast (default: luffy)

MACHINE="${1:-luffy}"
if [[ -z "$MACHINE" ]]; then
    echo "Error: Machine name parameter is empty." >&2
    exit 1
fi

echo "🔮 Forecasting cache hits for machine: ${MACHINE}"

if command -v nix-weather >/dev/null 2>&1; then
    echo "🔮  Using nix-weather for a detailed forecast…"
    # Build dry-run to collect store paths
    DERIVATIONS=$(nix build ".#nixosConfigurations.${MACHINE}.config.system.build.toplevel" \
        --no-link --dry-run --keep-going \
        | grep '^building' | awk '{print $2}')
    if [[ -z "$DERIVATIONS" ]]; then
        echo "ℹ️  No derivations to build – system is up to date."
        exit 0
    fi
    echo "$DERIVATIONS" | nix-weather forecast
else
    echo "⚠️  nix-weather not installed – showing a quick local‑cache summary."
    nix build ".#nixosConfigurations.${MACHINE}.config.system.build.toplevel" \
        --no-link --dry-run --keep-going \
        | grep '^building' | awk '{print $2}' \
        | while read -r store_path; do
            if nix store info "$store_path" | grep -q "substitutes: (none)"; then
                echo "❌  $store_path → NOT cached"
            else
                echo "✅  $store_path → cached"
            fi
        done
fi
