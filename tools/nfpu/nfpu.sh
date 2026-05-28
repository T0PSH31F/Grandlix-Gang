#!/usr/bin/env bash
# --------------------------------------------------------------
# nfpu – “NFP Update” helper
# --------------------------------------------------------------
set -euo pipefail
IFS=$'\n\t'

# ------------------- CONFIGURATION ---------------------------
# Path to your NFP repository (adjust if different)
REPO_ROOT="${HOME}/Clan/NFP"

# Whether to use nix-weather (if installed) for cache‑hit forecast
USE_NIX_WEATHER=true

# Command to watch live build output
BUILD_WATCHER="nix-output-monitor"

# --------------------------------------------------------------
# Helper functions
# --------------------------------------------------------------
header() { echo -e "\n\e[1;34m=== $1 ===\e[0m\n"; }
run() { "$@" || { echo "❌ Command failed: $*"; exit 1; }
}

# --------------------------------------------------------------
# 1️⃣ Load the repository and make sure we are up‑to‑date
# --------------------------------------------------------------
cd "${REPO_ROOT}"
run git fetch --quiet
run git status -sb   # show branch & ahead/behind

# --------------------------------------------------------------
# 2️⃣ Show a *fancy* diff of what will change
# --------------------------------------------------------------
header "Git diff (what will be pushed)"
run git diff --color=always

# --------------------------------------------------------------
# 3️⃣ Show the Nix build plan (what will be rebuilt)
# --------------------------------------------------------------
header "Nix build plan (what will be rebuilt)"
run "${REPO_ROOT}/tools/nfpu/lib/show_nix_plan.sh"

# --------------------------------------------------------------
# 4️⃣ Forecast binary‑cache hit‑rate
# --------------------------------------------------------------
header "Binary‑cache hit forecast"
MACHINES=("luffy" "z0r0")
if ${USE_NIX_WEATHER} && command -v nix-weather >/dev/null 2>&1; then
    for m in "${MACHINES[@]}"; do
        run "${REPO_ROOT}/tools/nfpu/lib/forecast_cache.sh" "$m"
    done
else
    echo "⚠️  nix-weather not installed – falling back to simple local cache check."
    # Simple local‑cache check (list missing substitutes)
    NIX_SUBST=${NIX_SUBSTITUTOR:-https://cache.nixos.org}
    echo "  → Checking ${NIX_SUBST} …"
    for m in "${MACHINES[@]}"; do
        echo "  → Checking cache for machine: $m"
        # Approximation: look for missing substitutes in the dry‑run output
        nix build "${REPO_ROOT}"/.#nixosConfigurations."${m}".config.system.build.toplevel \
            --no-link --dry-run --keep-going 2>/dev/null | \
            grep -E 'building|reusing' | grep -v "substitutes:" || true
    done
fi

# --------------------------------------------------------------
# 5️⃣ Prompt for manual confirmation
# --------------------------------------------------------------
read -p $'\nDo you want to proceed with `clan machines update`? (y/N) ' -r answer
if [[ ! $answer =~ ^[Yy]$ ]]; then
    echo "🚫  Update aborted by user."
    exit 0
fi

# --------------------------------------------------------------
# 6️⃣ Run the actual update, piping through the monitor
# --------------------------------------------------------------
header "Running `clan machines update` (live output)"
exec 3>&1 4>&2               # keep original stdout/stderr
{ clan machines update 2>&1 | ${BUILD_WATCHER}; } | tee "${REPO_ROOT}/nfpu_update_$(date +%Y%m%d_%H%M%S).log"
exec 1>&3 2>&4

header "✅ Update completed! Log saved in the repo root."
