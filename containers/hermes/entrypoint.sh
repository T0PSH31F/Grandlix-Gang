#!/usr/bin/env bash
set -euo pipefail

HERMES_HOME="${HERMES_HOME:-/data}"
HERMES_CONFIG="${HERMES_CONFIG_PATH:-${HERMES_HOME}/config.yaml}"
HERMES_WEBUI_DIR="${HERMES_WEBUI_DIR:-/opt/hermes-webui}"
GATEWAY_PORT="${HERMES_GATEWAY_PORT:-8642}"
DASHBOARD_PORT="${HERMES_DASHBOARD_PORT:-9119}"
WEBUI_PORT="${HERMES_WEBUI_PORT:-3000}"
WEBUI_HOST="${HERMES_WEBUI_HOST:-0.0.0.0}"

mkdir -p "$HERMES_HOME"

if [ ! -f "$HERMES_CONFIG" ]; then
  cat >"$HERMES_CONFIG" <<-'EOF'
_config_version: 29
terminal:
  backend: local
  modal_mode: auto
  timeout: 180
  container_persistent: true
  persistent_shell: true
  docker_image: "python:3.11-slim"
model:
  base_url: "http://127.0.0.1:1337/v1"
  default: "gpt-4o"
  provider: "custom"
  api_mode: "chat_completions"
web:
  backend: "firecrawl"
browser:
  engine: "auto"
dashboards:
  http:
    host: "0.0.0.0"
    port: 9119
    basic_auth:
      - username: "admin"
        password: "$(python3 -c 'import hashlib, base64; print(base64.b64encode(hashlib.scrypt(b"hermes", salt=b"hermes-salt", n=16384, r=8, p=1)).decode())')"
    theme: "cyberpunk"
    show_token_analytics: true
    show_session_explorer: true
    show_cost_breakdown: true
security:
  redact_secrets: true
toolsets:
  - "hermes-cli"
EOF
fi

PID_LIST=""
cleanup() {
  echo "Shutting down..."
  for pid in $PID_LIST; do
    kill "$pid" 2>/dev/null || true
  done
  wait
}
trap cleanup EXIT INT TERM

echo "Starting Hermes Agent gateway on port $GATEWAY_PORT..."
hermes gateway --port "$GATEWAY_PORT" &
PID_LIST="$PID_LIST $!"

sleep 2

echo "Starting Hermes Dashboard on $WEBUI_HOST:$DASHBOARD_PORT..."
hermes dashboard --port "$DASHBOARD_PORT" --host "0.0.0.0" --insecure --skip-build &
PID_LIST="$PID_LIST $!"

sleep 2

if [ -f "$HERMES_WEBUI_DIR/server.py" ]; then
  echo "Starting Hermes WebUI on $WEBUI_HOST:$WEBUI_PORT..."
  HERMES_WEBUI_PORT="$WEBUI_PORT" HERMES_WEBUI_HOST="0.0.0.0" python3 "$HERMES_WEBUI_DIR/server.py" &
  PID_LIST="$PID_LIST $!"
fi

echo "All services started. Waiting..."
wait
