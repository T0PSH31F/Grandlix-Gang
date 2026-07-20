#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
# gen-freellmapi-config.sh — Generate FreeLLMAPI declarative config from
# available secrets: sops + Spacedrive.txt
#
# This script reads keys from environment variables (exported by sops-nix via
# hermes-env) and from ~/Notes/Spacedrive.txt, then outputs a JSON config
# suitable for FREEAPI_CONFIG_PATH / FREEAPI_CONFIG_JSON.
#
# Missing provider keys are printed to stderr so Hermes can pick them up.
# ──────────────────────────────────────────────────────────────────────────────

CONFIG_FILE="${1:-/tmp/freellmapi-config.json}"
SPACEDRIVE="${SPACEDRIVE_FILE:-$HOME/Notes/Spacedrive.txt}"

# ── Helper: extract key from Spacedrive.txt by pattern ────────────────────────
get_sd() {
  local pattern="$1"
  [[ -f "$SPACEDRIVE" ]] && grep -i "$pattern" "$SPACEDRIVE" | head -1 | sed -E 's/.*[:=] *//' | xargs || true
}

# ── Read from env (sops) or Spacedrive.txt ────────────────────────────────────
read_key() {
  local var_name="$1"
  local sd_pattern="$2"
  local val="${!var_name}"
  if [[ -z "$val" ]]; then
    val=$(get_sd "$sd_pattern")
  fi
  echo "$val"
}

# ── Build the FreeLLMAPI config ───────────────────────────────────────────────
cat > "$CONFIG_FILE" << 'CONFIG_JSON'
{
  "routing": { "strategy": "balanced" },
  "keys": [
CONFIG_JSON

# Append a JSON entry for each provider we have a key for
first=true
add_key() {
  local platform="$1"
  local key="$2"
  local label="${3:-$platform}"
  [[ -z "$key" || "$key" == "dummy" || "$key" == "TODO" ]] && return
  $first || echo "," >> "$CONFIG_FILE"
  first=false
  cat >> "$CONFIG_FILE" << EOF
    { "platform": "$platform", "key": "$key", "label": "$label", "enabled": true }
EOF
}

# ── Map: hermes-env vars → FreeLLMAPI platforms ───────────────────────────────
add_key "openrouter"  "$(read_key OPENROUTER_API_KEY 'OpenRouter.*API')"          "openrouter-sops"
add_key "google"      "$(read_key GEMINI_API_KEY 'Gemini.*API')"                  "gemini-sops"
add_key "groq"        "$(read_key GROQ_API_KEY 'Groq')"                           "groq-sops"
add_key "cerebras"    "$(read_key CEREBRAS_API_KEY 'cerebras')"                   "cerebras-sops"
add_key "mistral"     "$(read_key MISTRAL_API_KEY 'Mistral AI API')"              "mistral-sops"
add_key "reka"        "$(read_key REKA_API_KEY 'Reka')"                           "reka-sops"
add_key "cohere"      "$(read_key COHERE_API_KEY 'Cohere')"                       "cohere-sops"
add_key "ai21"        "$(read_key AI21_API_KEY 'AI21')"                           "ai21-sops"
add_key "github"      "$(read_key GITHUB_TOKEN 'github models')"                  "github-sops"
add_key "nvidia"      "$(read_key NVIDIA_API_KEY 'NVIDIA')"                       "nvidia-sops"
add_key "huggingface" "$(read_key HF_TOKEN 'huggingface.*[Tt]oken')"              "huggingface-sops"
add_key "cloudflare"  "$(read_key CLOUDFLARE_API_TOKEN 'cloudflare.*[Tt]oken')"   "cloudflare-sops"
add_key "elevenlabs"  "$(read_key ELEVENLABS_API_KEY 'Elevenlabs')"               "elevenlabs-sops"
add_key "opencode"    "$(read_key OPENCODE_ZEN_API_KEY 'OpenCode')"               "opencode-zen-sops"

# ── Map: additional keys from Spacedrive.txt not in sops ──────────────────────
# These use generic search patterns pointing to entries in ~/Notes/Spacedrive.txt
# Format per line:  <provider>  "<label>"  "key label in Spacedrive.txt"
# Edit the patterns below to match the actual labels in YOUR Spacedrive.txt.
# Example: if Spacedrive.txt has "Gemini: AIzaSy..." then use get_sd 'Gemini'
add_key "google"      "$(get_sd 'Gemini.*WE77\|Gemini.*lovelain')"           "gemini-we77"
add_key "google"      "$(get_sd 'Gemini.*lovelain\|Gemini.*Lovelain')"       "gemini-lovelain"
add_key "openrouter"  "$(get_sd 'OpenRouter.*sk-or\|sk-or-v1')"            "openrouter-sd1"
add_key "openrouter"  "$(get_sd 'OpenRouter.*4d58\|sk-or-v1.*4d58')"       "openrouter-sd2"
add_key "groq"        "$(get_sd 'Groq.*gsk_\|gsk_')"                       "groq-wright"
add_key "mistral"     "$(get_sd 'Mistral.*N30l\|N30lIe')"                  "mistral-wright"
add_key "cerebras"    "$(get_sd 'Cerebras.*csk-\|csk-m94')"                "cerebras-wright"
add_key "cohere"      "$(get_sd 'Cohere.*w1dr\|w1drPTx')"                  "cohere-wright"
add_key "ai21"        "$(get_sd 'AI21.*fc27\|fc278d84')"                   "ai21-wright"
add_key "github"      "$(get_sd 'GitHub.*github_pat\|github_pat_11AZ')"    "github-sd"

# ── Write the remaining config skeleton ───────────────────────────────────────
cat >> "$CONFIG_FILE" << 'CONFIG_JSON'
  ],
  "models": [],
  "customProviders": []
}
CONFIG_JSON

echo "FreeLLMAPI config written to: $CONFIG_FILE"
echo ""
echo "── Missing Provider Keys ──────────────────────────────────────────────"
echo "Check the following providers in your FreeLLMAPI dashboard Keys page:"
echo ""

for provider in \
  "perplexity|Perplexity AI|https://perplexity.ai" \
  "together|Together AI|https://together.ai" \
  "deepinfra|DeepInfra|https://deepinfra.com" \
  "fireworks|Fireworks AI|https://fireworks.ai" \
  "anthropic|Anthropic Claude|https://anthropic.com" \
  "xai|xAI Grok|https://x.ai" \
  "zai|Z.ai (Zhipu)|https://z.ai" \
  "nebius|Nebius AI|https://nebius.com" \
  "sambanova|SambaNova|https://sambanova.ai" \
  "lepton|Lepton AI|https://lepton.ai" \
  "infermatic|Infermatic AI|https://infermatic.ai" \
; do
  IFS='|' read -r platform name url <<< "$provider"
  # Check if we have any key that could map to this platform
  existing_key=$(read_key "${platform}_API_KEY" "$platform" 2>/dev/null || echo "")
  if [[ -z "$existing_key" || "$existing_key" == "dummy" ]]; then
    echo "  ❌ $platform — $name"
    echo "     Get a key at: $url"
    echo "     Then add to:  Spacedrive.txt or sops"
    echo ""
  fi
done

echo "────────────────────────────────────────────────────────────────────────"
echo "Providers with keys above are configured. Add more via the FreeLLMAPI"
echo "dashboard at http://127.0.0.1:3001 or by editing $CONFIG_FILE"
echo ""
echo "Tip: Set FREEAPI_CONFIG_PATH=$CONFIG_FILE in the freellmapi service env"
