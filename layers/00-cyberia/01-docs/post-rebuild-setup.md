# Post-Rebuild Setup Guide

> After running `clan machines update z0r0` and `clan machines update luffy`
> Generated: 2026-08-14

## 1. ExtremeRouter Setup (z0r0)

ExtremeRouter replaces OmniRoute as the coding LLM router.

### First-Time Setup

1. **Open dashboard**: `http://z0r0:20128`

2. **Connect providers** (Dashboard → Providers):
   - **OpenRouter**: Paste your API key (already in SOPS as `openrouter_api_key_1/2/3`)
   - **Kiro AI**: Click Connect → AWS Builder ID or Google login → free Claude 4.5 unlimited
   - **OpenCode Free**: Click Connect → no auth needed, auto-fetches models

3. **Enable token savers** (Dashboard → Endpoint settings):
   - **RTK Token Saver**: ON by default (saves 20-40% input tokens)
   - **Caveman Mode**: Toggle ON for terse output (saves up to 65% output tokens)
   - **Ponytail**: Toggle ON for YAGNI-first code generation

4. **Create combos** (Dashboard → Combos → Create New):
   ```
   Name: free-combo
   Models:
     1. kr/claude-sonnet-4.5      (Kiro free)
     2. oc/<auto>                 (OpenCode Free)
   ```
   ```
   Name: premium-coding
   Models:
     1. or/anthropic/claude-opus-4.8  (OpenRouter)
     2. kr/claude-sonnet-4.5          (Kiro free fallback)
   ```

5. **Verify model discovery**:
   ```bash
   # Via Kong (what OpenCode/Hermes use) — proxy port is 8090
   curl -s http://localhost:8090/v1/models | python3 -m json.tool

   # Direct to ExtremeRouter (requires the remote API key)
   curl -s http://localhost:20128/v1/models \
     -H "Authorization: Bearer $EXTREMEROUTER_API_KEY" | python3 -m json.tool
   ```

## 2. Kong Gateway Verification (z0r0)

Kong is the unified entry point for all LLM traffic.

> **Port map** (correct as of 2026-09):
> - `8090` — Kong **proxy** (clients call `/v1/*`, `/llm/*` here)
> - `8091` — Kong **Admin API** (loopback, declarative config)
> - `8093` — Kong **Manager GUI / dashboard** (loopback: `http://127.0.0.1:8093`)

```bash
# Check Kong is running
curl -s http://localhost:8090/health

# Check routes
curl -s http://localhost:8090/v1/models

# Check coding route (should go to ExtremeRouter)
curl -s -X POST http://localhost:8090/llm/coding/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"auto","messages":[{"role":"user","content":"hello"}]}'
```

## 3. Hermes Agent Verification (z0r0)

```bash
# Check hermes is running
systemctl status hermes-agent

# Check hermes dashboard
curl -s http://localhost:9119/api/health

# Check hermes config has Kong provider
grep -A5 "name: kong" ~/.hermes/config.yaml

# Test hermes can reach Kong
hermes status
```

## 4. OpenCode Verification (z0r0)

```bash
# Check opencode version
opencode --version

# Check config has correct providers
cat ~/.config/opencode/opencode.json | python3 -c "import sys,json; d=json.load(sys.stdin); print(list(d.get('provider',{}).keys()))"

# Check oh-my-opencode-slim preset
cat ~/.config/opencode/oh-my-opencode-slim.json | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('preset'))"
```

## 5. MCP Servers Verification (z0r0)

```bash
# Check MCP servers are configured
cat ~/.config/opencode/opencode.json | python3 -c "
import sys,json
d=json.load(sys.stdin)
mcps = d.get('mcp',{})
for name, cfg in mcps.items():
    enabled = cfg.get('enabled', True)
    print(f'  {name}: {\"enabled\" if enabled else \"disabled\"}')" 

# Expected enabled MCPs:
# - codegraph
# - himalaya
# - ncp
# - forage
# - mistral
# - github
# - context-mode
# - forage
# - mcp-nixos
# - sequential-thinking
```

## 6. Brain Service PKB Verification (z0r0)

```bash
# Check brain service is running
curl -s http://localhost:8010/health

# Check ingested docs
curl -s http://localhost:8010/manifest | python3 -c "
import sys,json
d=json.load(sys.stdin)
print(f'Total files: {len(d.get(\"files\",{}))}')" 

# Test RAG query
curl -s -X POST http://localhost:8010/query \
  -H "Content-Type: application/json" \
  -d '{"question": "How do I configure impermanence with BTRFS?"}' | \
  python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('answer','no answer')[:500])"
```

## 7. Other Services Verification (z0r0)

```bash
# Hermes services
systemctl status hermes-agent hermes-dashboard hermes-workspace

# AI services
systemctl status brain-service llama-cpp-server ollama freellmapi freellmpool mistral-mcp

# Communication
systemctl status signal-cli-daemon camofox-browser

# Monitoring
systemctl status prometheus grafana loki glances

# Langfuse
curl -s http://localhost:3005/api/public/health
```

## 8. Skills Verification (z0r0)

```bash
# Check oh-my-opencode-slim skills manifest
cat ~/.config/opencode/.oh-my-opencode-slim/skills-manifest.json | python3 -c "
import sys,json
d=json.load(sys.stdin)
skills = d.get('skills',{})
for name, info in skills.items():
    status = info.get('status','unknown')
    version = info.get('packageVersion','?')
    print(f'  {name}: {status} (v{version})')" 

# Expected skills:
# - simplify: customized
# - codemap: customized
# - clonedeps: customized
# - deepwork: managed
# - reflect: customized
# - worktrees: managed
# - verification-planning: managed
```

## 9. Luffy Verification

```bash
# SSH to luffy
ssh root@192.168.1.54

# Check services
systemctl status hermes-agent hermes-dashboard

# Check homepage dashboard
curl -s http://localhost:3007/api/health

# Check matrix
curl -s http://localhost:8008/_matrix/client/versions
```

## 10. Troubleshooting

### ExtremeRouter not showing models
- Check container is running: `podman ps | grep extreme`
- Check logs: `podman logs extreme-router`
- Restart: `systemctl restart podman-extreme-router`

### Kong not routing to ExtremeRouter
- Check Kong config: `curl -s http://localhost:8091/routes`
- Verify codingRouter setting: `grep codingRouter machines/z0r0/default.nix`
- Check Kong logs: `journalctl -u podman-kong`
- Verify upstream auth header is injected: `curl -s http://localhost:8091/plugins | jq '.data[] | select(.service.name=="extremerouter-llm")'`

### Hermes can't reach Kong
- Check KONG_API_KEY is set: `grep KONG_API_KEY ~/.hermes/config.yaml`
- Check hermes-env: `cat /run/secrets/hermes-env | grep KONG`
- Restart hermes: `systemctl restart hermes-agent`

### OpenCode can't enumerate models
- Check opencode.json provider config
- Verify Kong /v1/models endpoint: `curl http://localhost:8090/v1/models`
- Check OpenCode logs: `journalctl -u opencode`

## Quick Reference

| Service | Port | URL |
|---------|------|-----|
| Kong Gateway (proxy) | 8090 | http://z0r0:8090 |
| Kong Manager GUI | 8093 | http://127.0.0.1:8093 (loopback) |
| Kong Admin API | 8091 | http://127.0.0.1:8091 (loopback) |
| ExtremeRouter | 20128 | http://z0r0:20128 |
| Hermes Dashboard | 9119 | http://z0r0:9119 |
| Brain Service | 8010 | http://z0r0:8010 |
| Grafana | 3008 | http://z0r0:3008 |
| Langfuse | 3005 | http://z0r0:3005 |
| FreeLLMAPI | 3003 | http://z0r0:3003 |
| Mistral MCP | 3333 | http://z0r0:3333 |
