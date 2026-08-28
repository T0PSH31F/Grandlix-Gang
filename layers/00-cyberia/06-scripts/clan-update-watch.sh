#!/usr/bin/env bash
# clan-update-watch.sh
# Restores nom/nh-style build progress for `clan machines update`, then runs
# a remote health check immediately after activation.
#
# Why: `clan machines update` wraps nix internally and doesn't expose
# -v/-L/--show-trace passthrough to the build, so you lose nom/nh-style
# progress. This script builds the closure yourself (with full nom output),
# then lets clan do the now-cached copy+activate, then health-checks the box.
#
# Usage:
#   ./clan-update-watch.sh <machine> [flake-path] [--no-health] [--target-host user@host]
#
# Requires: nix-output-monitor (nom) — installed on the fly via `nix shell`
# if not already on PATH. Requires the nixos-healthcheck.sh script
# (from an earlier conversation) placed alongside this script, or set
# HEALTHCHECK_SCRIPT to its path.

set -euo pipefail

MACHINE=""
FLAKE="."
RUN_HEALTH=1
TARGET_HOST=""
HEALTHCHECK_SCRIPT="${HEALTHCHECK_SCRIPT:-$(dirname "$0")/nixos-healthcheck.sh}"

while [ $# -gt 0 ]; do
  case "$1" in
  --no-health) RUN_HEALTH=0 ;;
  --target-host)
    TARGET_HOST="$2"
    shift
    ;;
  -*)
    echo "Unknown option: $1" >&2
    exit 1
    ;;
  *)
    if [ -z "$MACHINE" ]; then
      MACHINE="$1"
    elif [ "$FLAKE" = "." ]; then
      FLAKE="$1"
    fi
    ;;
  esac
  shift
done

if [ -z "$MACHINE" ]; then
  echo "Usage: $0 <machine> [flake-path] [--no-health] [--target-host user@host]" >&2
  exit 1
fi

BLU=$'\033[34m'
GRN=$'\033[32m'
YEL=$'\033[33m'
RST=$'\033[0m'
section() {
  echo ""
  echo "${BLU}==== $* ====${RST}"
}

have() { command -v "$1" >/dev/null 2>&1; }
nom_run() {
  if have nom; then nom "$@"; else nix shell nixpkgs#nix-output-monitor -c nom "$@"; fi
}

# ---------------------------------------------------------------------------
section "1/3 Building ${MACHINE} closure with nom (full progress tree)"
ATTR="${FLAKE}#nixosConfigurations.${MACHINE}.config.system.build.toplevel"
echo "Building: $ATTR"
nom_run build "$ATTR" --no-link --print-out-paths | tee /tmp/clan-update-watch-outpath.txt
BUILT_PATH=$(tail -n1 /tmp/clan-update-watch-outpath.txt)
echo "${GRN}Built:${RST} $BUILT_PATH"

# ---------------------------------------------------------------------------
section "2/3 Handing off to clan machines update (should now be fast/cached)"
CLAN_ARGS=(machines update "$MACHINE")
[ -n "$TARGET_HOST" ] && CLAN_ARGS+=(--target-host "$TARGET_HOST")
clan "${CLAN_ARGS[@]}"
CLAN_EXIT=$?

if [ $CLAN_EXIT -ne 0 ]; then
  echo "${YEL}clan machines update exited with code ${CLAN_EXIT}. Skipping health check.${RST}" >&2
  exit $CLAN_EXIT
fi

# ---------------------------------------------------------------------------
if [ "$RUN_HEALTH" -eq 1 ]; then
  section "3/3 Post-update health check on ${MACHINE}"
  if [ -z "$TARGET_HOST" ]; then
    # Try to resolve target host from clan's inventory if not given explicitly
    TARGET_HOST=$(clan machines list --tags "$MACHINE" 2>/dev/null | grep -m1 "$MACHINE" || true)
  fi

  if [ -n "$HEALTHCHECK_SCRIPT" ] && [ -f "$HEALTHCHECK_SCRIPT" ]; then
    if [ -n "$TARGET_HOST" ]; then
      echo "Running health check remotely on $TARGET_HOST ..."
      ssh "$TARGET_HOST" 'bash -s' -- --bench-off <"$HEALTHCHECK_SCRIPT" || true
    else
      echo "No target host resolved; running health check locally (assumes this IS the machine)."
      bash "$HEALTHCHECK_SCRIPT" || true
    fi
  else
    echo "${YEL}Health check script not found at ${HEALTHCHECK_SCRIPT}. Set HEALTHCHECK_SCRIPT env var or place nixos-healthcheck.sh next to this file.${RST}"
  fi

  # Clan-specific container/service checks (systemd-nspawn / podman-backed clan services)
  echo ""
  echo "-- Clan-managed container/service status --"
  if [ -n "$TARGET_HOST" ]; then
    ssh "$TARGET_HOST" '
      echo "systemd-nspawn containers:"; machinectl list 2>/dev/null || echo "  none / machinectl unavailable"
      echo "podman containers:"; podman ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "  none / podman unavailable"
      echo "clan-managed services (units tagged clan):"; systemctl list-units --no-legend "clan-*" 2>/dev/null || true
    '
  fi
fi

echo ""
echo "${GRN}Done.${RST}"
