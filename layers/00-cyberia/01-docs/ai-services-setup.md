# AI Agent Services — Setup & Status

## Services Running on z0r0

| Service | Port | Status | Purpose |
|---------|------|--------|---------|
| hermes-agent | 8085 | ✅ Running | Hermes Agent Gateway (MCP) |
| hermes-dashboard | 9119 | ✅ Running | Web Dashboard |
| hermes-workspace | 3000 | ✅ Running | WebUI (nesquena/hermes-webui) |
| brain-service | 8010 | ✅ Running | PKB RAG API |
| llama-cpp-server | 8081 | ✅ Running | Local LLM (Llama3.3-8B) |
| ollama | 11434 | ✅ Running | Ollama LLM server |
| freellmapi | 3003 | ✅ Running | Free-tier LLM router |
| freellmpool | 8082 | ✅ Running | Free-tier LLM pool |
| mistral-mcp | 3333 | ✅ Running | Mistral AI tools |
| camofox-browser | 9377 | ✅ Running | Anti-detection browser |
| signal-cli-daemon | 8080 | ✅ Running | Signal messaging |
| aionui | 3006 | ✅ Running | AI Cowork web UI |
| langfuse | 3005 | ✅ Running | LLM observability |
| prometheus | 9090 | ✅ Running | Metrics |
| grafana | 3008 | ✅ Running | Dashboards |
| loki | 3100 | ✅ Running | Logs |
| glances | 61208 | ✅ Running | System stats |
| kong-gateway | 8081 | ✅ Running | Unified LLM/API gateway |

## Hermes Agent

### Skin Configuration
- **Fixed**: Changed from `slate` (non-existent) to `catppuccin`
- Available skins: bubblegum-80s, catppuccin, dos, empire, lain, mother, mythos, neonwave, netrunner, nous, pirate, sakura, skynet, telemate, vault-tec
- Location: `~/.hermes/skins/`

### Personalities Configured
20 personalities available including: glados (default), jarvis, cortana, hal, catgirl, pirate, noir, samantha, teacher, technical, etc.

### MCP Servers Enabled
- context7, file-manager, git, github, google-drive, mcp-nixos, mcp-registry, postgres, sqlite, himalaya, hermes-studio (api/devices/use)

## AI Routers Configuration

### OpenRouter (Primary)
- **Status**: Configured with multiple models
- **Models**: deepseek-v4-flash:free, gemini-3-pro, kimi-k2.6:free, llama-3.3-70b:free, minimax-m2.5:free, nemotron-3-super-120b:free, qwen3.6-max, grok-4.3
- **API Key**: In SOPS (`openrouter_api_key_1/2/3`)
- **Credential Pool**: round_robin strategy

### Nous Research
- **Status**: Configured as default provider
- **Model**: stepfun/step-3.7-flash:free
- **Base URL**: https://inference-api.nousresearch.com/v1
- **API Key**: Needs OAuth setup via `hermes auth`

### Local LLM (llama.cpp)
- **Status**: Running
- **Model**: Llama3.3-8B-Instruct-Thinking-Heretic-Uncensored
- **Port**: 8081 (via Kong gateway)
- **Context**: 8192 tokens

### Mistral MCP
- **Status**: Running on port 3333
- **API Key**: In SOPS (`mistral_api_key`) — may need updating

### FreeLLMAPI/FreeLLMPool
- **Status**: Running
- **Port**: 3003 (API), 8082 (Pool)
- **Purpose**: Free-tier LLM fallback

## What Needs User Setup

### 1. API Keys (SOPS-managed)
These are in `layers/00-cyberia/03-treasure/secrets/external_services.yaml`:
- `openrouter_api_key_1/2/3` — OpenRouter API keys
- `nous_api_key` — Nous Research API key
- `mistral_api_key` — Mistral API key
- `gemini_api_key_lovelain/we77` — Gemini API keys
- `langfuse_public_key/secret_key` — Langfuse credentials

**Action**: Run `clan vars generate z0r0` to set these if not already done.

### 2. Kong Gateway Environment
Kong needs environment variables for upstream LLM routing. These are in SOPS templates:
- `kong-env` template in `machines/z0r0/default.nix`

**Action**: Verify SOPS secrets are populated for:
- `OPENROUTER_API_KEY`
- `NOUS_API_KEY`
- `MISTRAL_API_KEY`

### 3. Brain Service MCP Integration
Currently disabled in opencode config (`mcpEnable = false`) due to pymupdf test failures.

**Action**: To enable, set `mcpEnable = true` in `layers/70-agents/71-coding/opencode.nix` after fixing pymupdf.

### 4. Langfuse Observability
Running on port 3005 but needs credentials configured.

**Action**: Set `LANGFUSE_PUBLIC_KEY` and `LANGFUSE_SECRET_KEY` in SOPS.

### 5. Matrix Integration
Hermes is connected to Matrix on luffy (192.168.1.54:8087).

**Action**: Verify Matrix access token is valid in hermes config.

### 6. Signal Integration
signal-cli-daemon running on port 8080.

**Action**: Verify Signal registration is active.

### 7. Camofox Browser
Running on port 9377 with VNC on 6080.

**Action**: For Google OAuth, use VNC at `http://z0r0:6080` to complete login.

### 8. AionUi Setup & Credentials
AionUi runs as a system service for user `t0psh31f` on port 3006 (`127.0.0.1:3006`).
- **Data directory**: `/var/lib/aionui` (persisted under `/persist/var/lib/aionui`).
- **User accounts**: Accounts created via the web UI are stored in SQLite database in `/var/lib/aionui/`.
- **First-run setup**: On first launch, open `http://127.0.0.1:3006` to register the initial user account. Credentials and settings survive reboot and rebuild.
- **Agent detection**: System PATH includes `/run/current-system/sw/bin` and user profile bin paths, enabling automatic detection of `claude-code`, `codex`, `gemini-cli`, and `opencode`. Skills installed by AionUi write directly to `/home/t0psh31f/.claude`, `.codex`, `.gemini`, and `.opencode`.

## Deployment Commands

```bash
# Generate all missing vars (prompts for passwords)
clan vars generate z0r0
clan vars generate luffy

# Deploy to z0r0
clan machines update z0r0

# Deploy to luffy (when online)
clan machines update luffy
```

## Post-Deploy Verification

```bash
# Check all services
systemctl list-units --type=service --state=running | grep -E "hermes|brain|llama|kong|ollama|signal|camofox|aionui|langfuse|freellm|mistral"

# Test Brain Service RAG
curl -s -X POST http://localhost:8010/query -H "Content-Type: application/json" -d '{"question": "test"}'

# Test Hermes Dashboard
curl -s http://localhost:9119/api/health

# Test OpenCode
opencode --version
```
