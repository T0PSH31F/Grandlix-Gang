#!/usr/bin/env bash
set -euo pipefail

# Forecast binary cache hits for upcoming NFP update.
# Uses nix-weather if installed; otherwise falls back to a simple local cache check.

if command -v nix-weather >/dev/null 2>&1; then
    echo "🔮  Using nix-weather for a detailed forecast…"
    # Build dry-run to collect store paths
    DERIVATIONS=$(nix build ".#nixosConfigurations.luffy.config.system.build.toplevel" \
        --no-link --dry-run --keep-going \
        | grep '^building' | awk '{print $2}')
    echo "$DERIVATIONS" | nix-weather forecast
else
    echo "⚠️  nix-weather not installed – showing a quick local‑cache summary."
    nix build ".#nixosConfigurations.luffy.config.system.build.toplevel" \
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
