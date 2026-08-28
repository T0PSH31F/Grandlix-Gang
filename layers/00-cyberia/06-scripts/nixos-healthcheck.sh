#!/usr/bin/env bash
# nixos-healthcheck.sh — Lightweight post-activation health check for NixOS fleet hosts
set -euo pipefail

echo "=== System Health Check ==="
echo "Host: $(hostname)"
echo "Uptime: $(uptime -p)"

echo ""
echo "-- Failed Systemd Units --"
failed_units=$(systemctl list-units --state=failed --no-legend)
if [ -z "$failed_units" ]; then
  echo "All systemd units healthy (0 failed)."
else
  echo "$failed_units"
fi

echo ""
echo "-- Memory & Swap --"
free -h

echo ""
echo "-- Disk Space --"
df -h / /persist 2>/dev/null || df -h /

echo ""
echo "-- Recent High-Priority Journal Errors --"
journalctl -p 3 -n 10 --no-pager 2>/dev/null || echo "No high-priority errors in journal."

echo ""
echo "=== Health Check Complete ==="
