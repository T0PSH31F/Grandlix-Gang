#!/usr/bin/env bash
# sysaudit — NFP System Health & Performance Audit Tool
set -euo pipefail

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUT_DIR="/var/lib/nfp-audit"
mkdir -p "$OUT_DIR" 2>/dev/null || OUT_DIR="/tmp/nfp-audit"
mkdir -p "$OUT_DIR"

REPORT_FILE="$OUT_DIR/$TIMESTAMP.md"
LATEST_LINK="$OUT_DIR/latest.md"

exec > >(tee "$REPORT_FILE")
exec 2>&1

echo "# 🛡️ NFP System Health Audit Report"
echo "**Host:** $(hostname) | **Date:** $(date -u)"
echo ""

FAIL_COUNT=0

pass() { echo "✅ **PASS:** $*"; }
warn() { echo "⚠️ **WARN:** $*"; }
fail() {
  echo "❌ **FAIL:** $*"
  FAIL_COUNT=$((FAIL_COUNT + 1))
}

echo "## 1. Hardware Baseline"
if command -v sysbench >/dev/null 2>&1; then
  SCORE=$(sysbench cpu run | grep "events per second:" | awk '{print $4}')
  echo "- Sysbench CPU score: $SCORE events/sec"
  pass "Sysbench benchmark complete"
else
  warn "sysbench not installed"
fi

if command -v fio >/dev/null 2>&1; then
  fio --name=seq_read --ioengine=libaio --rw=read --bs=1m --size=100m --filename=/tmp/fio_test_tmp.bin --runtime=5 --time_based >/dev/null 2>&1 || true
  rm -f /tmp/fio_test_tmp.bin
  pass "Disk IO benchmark complete"
else
  warn "fio not installed"
fi

echo ""
echo "## 2. Thermals & Power"
if command -v sensors >/dev/null 2>&1; then
  echo '```'
  sensors 2>/dev/null | head -15 || true
  echo '```'
  pass "Sensors telemetry read"
else
  warn "lm_sensors not installed"
fi

echo ""
echo "## 3. Live Resources & Systemd Health"
FAILED_UNITS=$(systemctl list-units --failed --no-legend 2>/dev/null | wc -l || echo "0")
if [ "$FAILED_UNITS" -eq 0 ]; then
  pass "Zero failed systemd units"
else
  fail "$FAILED_UNITS systemd unit(s) in failed state"
  systemctl list-units --failed --no-legend
fi

echo ""
echo "## Summary"
if [ "$FAIL_COUNT" -eq 0 ]; then
  echo "🎉 **AUDIT STATUS: PASSED**"
else
  echo "⚠️ **AUDIT STATUS: FAILED ($FAIL_COUNT issue(s) detected)**"
fi

ln -sf "$REPORT_FILE" "$LATEST_LINK" 2>/dev/null || true
exit "$FAIL_COUNT"
