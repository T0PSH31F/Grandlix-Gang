#!/usr/bin/env bash
# NFP harness initialization — run at the start of every agent session.
# Edit the three command arrays only if the repo's verification path changes.
set -euo pipefail

INSTALL_CMD=(true)                     # deps are pinned via flake.lock; nothing to install
VERIFY_CMD=(nix flake check)          # baseline verification
START_CMD=(clan machines list)        # fleet sanity check (read-only)

echo "==> [1/5] Dependency step"
"${INSTALL_CMD[@]}"

echo "==> [2/5] Format & linter check (nixfmt, deadnix, statix)"
nix fmt -- --check
deadnix --fail . || echo "    (deadnix check failed or uninstalled — check files)"
statix check . || echo "    (statix check failed or uninstalled — check files)"

echo "==> [3/5] Baseline verification"
"${VERIFY_CMD[@]}"

echo "==> [4/5] Machine evaluation (luffy, z0r0)"
nix eval --raw .#nixosConfigurations.luffy.config.system.build.toplevel.drvPath > /dev/null
nix eval --raw .#nixosConfigurations.z0r0.config.system.build.toplevel.drvPath > /dev/null
echo "    both machines evaluate"

echo "==> [5/5] Fleet visibility"
"${START_CMD[@]}" || echo "    (clan CLI unavailable locally — non-fatal)"

echo "==> Harness initialized. Read agent-progress.md and feature_list.json next."
