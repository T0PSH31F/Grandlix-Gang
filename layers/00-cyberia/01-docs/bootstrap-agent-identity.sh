#!/usr/bin/env bash
# bootstrap-agent-identity.sh
# Provisions gateway identities for a new Hermes profile:
#   - Matrix: fully automated via the Synapse admin API (self-hosted only).
#   - Telegram: bot *creation* is NOT automatable via the official Bot API
#     (BotFather has no REST endpoint for this). This script automates
#     everything AFTER you paste the token from a one-time manual BotFather
#     chat. Do not script the BotFather conversation via a scraped MTProto
#     session for unattended/bulk creation — it works today but is outside
#     the documented API surface and can get flagged at scale.
#
# Usage:
#   ./bootstrap-agent-identity.sh <profile-name> <telegram-home-channel-id> <matrix-home-room-id>
#
# Requires: curl, jq, sops (for writing secrets into the profile's .env
# via sops-nix rather than plaintext).

set -euo pipefail

PROFILE="${1:?Usage: $0 <profile-name> <telegram-home-channel-id> <matrix-home-room-id>}"
TELEGRAM_HOME_CHANNEL="${2:?Missing telegram home channel id}"
MATRIX_HOME_ROOM="${3:?Missing matrix home room id}"

SYNAPSE_URL="${SYNAPSE_URL:-http://localhost:8008}"
SYNAPSE_SHARED_SECRET="${SYNAPSE_SHARED_SECRET:?Set SYNAPSE_SHARED_SECRET env var (from homeserver.yaml registration_shared_secret)}"
SOPS_SECRETS_FILE="${SOPS_SECRETS_FILE:-$HOME/.nixconf/sops/agent-secrets.yaml}"

BLU=$'\033[34m'
GRN=$'\033[32m'
YEL=$'\033[33m'
RST=$'\033[0m'

echo "${BLU}== Provisioning identity for profile: ${PROFILE} ==${RST}"

# ---------------------------------------------------------------------------
echo ""
echo "${BLU}[1/3] Matrix — automated via Synapse admin API${RST}"

MATRIX_USERNAME="agent-${PROFILE}"
MATRIX_PASSWORD=$(openssl rand -base64 24)

# Synapse's shared-secret registration flow: get a nonce, then HMAC it.
NONCE=$(curl -s "${SYNAPSE_URL}/_synapse/admin/v1/register" | jq -r '.nonce')
MAC=$(printf '%s\0%s\0%s\0%s' "$NONCE" "$MATRIX_USERNAME" "$MATRIX_PASSWORD" "notadmin" |
  openssl dgst -sha1 -hmac "$SYNAPSE_SHARED_SECRET" -hex | awk '{print $2}')

REGISTER_RESP=$(curl -s -X POST "${SYNAPSE_URL}/_synapse/admin/v1/register" \
  -H "Content-Type: application/json" \
  -d "{\"nonce\":\"${NONCE}\",\"username\":\"${MATRIX_USERNAME}\",\"password\":\"${MATRIX_PASSWORD}\",\"mac\":\"${MAC}\",\"admin\":false}")

MATRIX_USER_ID=$(echo "$REGISTER_RESP" | jq -r '.user_id')
MATRIX_ACCESS_TOKEN=$(echo "$REGISTER_RESP" | jq -r '.access_token')

if [ -z "$MATRIX_USER_ID" ] || [ "$MATRIX_USER_ID" == "null" ]; then
  echo "${YEL}Matrix registration failed. Response:${RST} $REGISTER_RESP" >&2
  exit 1
fi
echo "${GRN}Created Matrix identity:${RST} $MATRIX_USER_ID"

# Join the shared home room so this identity can post there immediately.
curl -s -X POST "${SYNAPSE_URL}/_matrix/client/v3/join/${MATRIX_HOME_ROOM}" \
  -H "Authorization: Bearer ${MATRIX_ACCESS_TOKEN}" >/dev/null
echo "${GRN}Joined shared room:${RST} $MATRIX_HOME_ROOM"

# ---------------------------------------------------------------------------
echo ""
echo "${BLU}[2/3] Telegram — manual token creation required${RST}"
echo "${YEL}Bot creation cannot be automated via the official Bot API.${RST}"
echo "Do this once, manually, in Telegram:"
echo "  1. Open a chat with @BotFather"
echo "  2. Send: /newbot"
echo "  3. Name it something like: ${PROFILE} agent"
echo "  4. Username must end in 'bot', e.g. ${PROFILE}_nfp_bot"
echo "  5. Copy the token BotFather returns"
echo ""
read -rp "Paste the Telegram bot token for '${PROFILE}' now: " TELEGRAM_BOT_TOKEN

if [ -z "$TELEGRAM_BOT_TOKEN" ]; then
  echo "${YEL}No token provided — skipping Telegram wiring for this profile.${RST}"
fi

# Remind the bot to join the shared group (adding a bot to a group also
# can't be done via the Bot API alone — an existing group member must
# /invite it, or the group admin adds @<bot_username> manually once).
if [ -n "$TELEGRAM_BOT_TOKEN" ]; then
  BOT_INFO=$(curl -s "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getMe")
  BOT_USERNAME=$(echo "$BOT_INFO" | jq -r '.result.username')
  echo "${YEL}Now add @${BOT_USERNAME} to the shared group (chat id ${TELEGRAM_HOME_CHANNEL}) as a member — this step also requires a human/admin action once per bot.${RST}"
fi

# ---------------------------------------------------------------------------
echo ""
echo "${BLU}[3/3] Writing secrets into sops-nix${RST}"

if ! command -v sops >/dev/null 2>&1; then
  echo "${YEL}sops not found — printing values instead. Add these manually:${RST}"
  echo "MATRIX_USER_ID_${PROFILE}=${MATRIX_USER_ID}"
  echo "MATRIX_ACCESS_TOKEN_${PROFILE}=${MATRIX_ACCESS_TOKEN}"
  [ -n "${TELEGRAM_BOT_TOKEN:-}" ] && echo "TELEGRAM_BOT_TOKEN_${PROFILE}=${TELEGRAM_BOT_TOKEN}"
  exit 0
fi

sops set "$SOPS_SECRETS_FILE" "[\"${PROFILE}\"][\"matrix_user_id\"]" "\"${MATRIX_USER_ID}\""
sops set "$SOPS_SECRETS_FILE" "[\"${PROFILE}\"][\"matrix_access_token\"]" "\"${MATRIX_ACCESS_TOKEN}\""
sops set "$SOPS_SECRETS_FILE" "[\"${PROFILE}\"][\"matrix_home_room\"]" "\"${MATRIX_HOME_ROOM}\""
if [ -n "${TELEGRAM_BOT_TOKEN:-}" ]; then
  sops set "$SOPS_SECRETS_FILE" "[\"${PROFILE}\"][\"telegram_bot_token\"]" "\"${TELEGRAM_BOT_TOKEN}\""
  sops set "$SOPS_SECRETS_FILE" "[\"${PROFILE}\"][\"telegram_home_channel\"]" "\"${TELEGRAM_HOME_CHANNEL}\""
fi

echo "${GRN}Done.${RST} Secrets written to ${SOPS_SECRETS_FILE} under key '${PROFILE}'."
echo "Wire these into the profile's sops-nix secret declarations, then run:"
echo "  hermes profile install ./profile-template --name ${PROFILE}"
