#!/bin/bash
# Hermes Evaluator — Proposal Review Launcher
# Shows latest evaluator report in rofi

REPORTS_DIR="$HOME/.hermes/evaluator/reports"
LATEST=$(ls -t "$REPORTS_DIR"/*.md 2>/dev/null | head -1)

if [ -z "$LATEST" ]; then
  echo "No evaluator reports found" | rofi -dmenu -p "Evaluator"
  exit 0
fi

# Show report content in rofi
cat "$LATEST" | rofi -dmenu -p "Evaluator Report" -filter ""
