# Port Allocation Registry

> **Last updated:** 2026-08-09
> **Purpose:** Quick reference to avoid port conflicts when adding new services.

## Legend
- **z0r0** = LG laptop workstation
- **luffy** = Intel 9th-gen homelab server
- **Both** = deployed on both machines

---

## Port Map

| Port | Service | Machine | Config File | Notes |
|------|---------|---------|-------------|-------|
| **389** | Vaultwarden LDAP | luffy | `layers/20-services/25-data/vaultwarden.nix` | LDAP interface |
| **465** | himalaya SMTPS | z0r0 | `layers/50-cli-tui-programs/53-tools/himalaya.nix` | Email client SMTP |
| **993** | himalaya IMAPS | z0r0 | `layers/50-cli-tui-programs/53-tools/himalaya.nix` | Email client IMAP |
| **3001** | Grafana | luffy | `machines/luffy/default.nix` | Monitoring dashboards |
| **3001** | HedgeDoc | z0r0 | `machines/z0r0/default.nix` | Collaborative markdown |
| **3001** | Grafana | z0r0 | Moved to 3008 | |
| **3002** | Lovable | luffy | `machines/luffy/default.nix` | AI app builder |
| **3003** | FreeLLMAPI | z0r0 | `machines/z0r0/default.nix` | Free-tier LLM router |
| **3007** | N8N | luffy | `machines/luffy/default.nix` | Workflow automation |
| **3008** | Grafana (z0r0 override) | z0r0 | `machines/z0r0/default.nix` | Avoids conflict with homepage on 3000 |
| **3100** | Loki | z0r0 | `machines/z0r0/default.nix` | Log aggregation |
| **3333** | Mistral MCP | z0r0 | `machines/z0r0/default.nix` | Mistral AI tool server (chat, OCR, Codestral) |
| **5678** | N8N | luffy | `machines/luffy/default.nix` | Workflow automation (also used in tests) |
| **6334** | Qdrant gRPC | z0r0 | `layers/20-services/22-ai/qdrant.nix` | Vector database |
| **6380** | Nextcloud | luffy | `layers/20-services/25-data/nextcloud.nix` | File sync |
| **8008** | Matrix Synapse | luffy | `machines/luffy/default.nix` | Matrix homeserver |
| **8010** | Brain Service | z0r0 | `machines/z0r0/default.nix` | Personal Knowledge Base (PDF/EPUB/HTML/MD RAG) |
| **8080** | Signal CLI | z0r0 | `machines/z0r0/default.nix` | Signal messenger daemon |
| **8081** | Kong Gateway | z0r0 | `machines/z0r0/default.nix` | Unified LLM/API gateway |
| **8082** | FreeLLMPool | z0r0 | `machines/z0r0/default.nix` | Free-tier LLM pool |
| **8084** | Paperless-ngx | luffy | `machines/luffy/default.nix` | Document management |
| **8087** | Mealie | luffy | `machines/luffy/default.nix` | Recipe manager |
| **8443** | HTTPS alt | luffy | `machines/luffy/default.nix` | Alternative HTTPS |
| **8444** | HTTPS alt 2 | luffy | `machines/luffy/default.nix` | Alternative HTTPS |
| **9090** | Prometheus | both | `machines/*/default.nix` | Metrics collection |
| **9100** | Glances | z0r0 | `layers/20-services/26-monitoring/monitoring.nix` | System monitoring |
| **9119** | Hermes Dashboard | z0r0 | `layers/70-agents/76-hermes-agent/hermes.nix` | Agent dashboard |
| **9377** | Camofox Browser | z0r0 | `machines/z0r0/default.nix` | Anti-detection browser |

---

## Additional Ports (from service modules)

| Port | Service | Machine | Config File | Notes |
|------|---------|---------|-------------|-------|
| **22** | SSH | both | system | Standard SSH |
| **51820** | WireGuard | both | `layers/20-services/` | VPN tunnel |
| **5000** | Harmonia (nix-cache) | luffy | `layers/20-services/28-clan-services/nix-cache/` | Nix binary cache |
| **53** | AdGuard | luffy | `layers/20-services/` | DNS |
| **3000** | Homepage Dashboard | luffy | `layers/20-services/26-monitoring/` | Service dashboard |
| **3005** | Langfuse | z0r0 | `machines/z0r0/default.nix` | LLM observability |
| **3006** | AionUI | z0r0 | `layers/20-services/22-ai/aionui.nix` | AI cowork web UI |
| **3099** | Mission Control | z0r0 | `machines/z0r0/default.nix` | Container management |
| **5680** | OpenCompany | luffy | `layers/20-services/22-ai/opencompany.nix` | AI workflow canvas |
| **5681** | OpenCompany Backend | luffy | `layers/20-services/22-ai/opencompany.nix` | Python backend |
| **6080** | VNC | z0r0 | `layers/20-services/24-communication/` | Camofox VNC |
| **8000** | SillyTavern | z0r0 | `machines/z0r0/default.nix` | LLM chat UI |

---

## Disabled Services (ports reserved but unused)

| Port | Service | Machine | Reason |
|------|---------|---------|--------|
| **3001** | FreeLLMAPI | z0r0 | Source hash mismatch, needs pinning |
| **3001** | Grafana | z0r0 | Moved to 3008 |
| **9090** | Prometheus | z0r0 | Moved to luffy |
| **8080** | AdGuard | z0r0 | Moved to luffy |

---

## Port Conflict Rules

1. **Before adding a new service**, check this file for the desired port
2. **Default ports** (e.g., 3000, 8080, 8000) are often claimed — always verify
3. **Document immediately** when assigning a port to a new service
4. **Use `lib.mkForce`** to override defaults when conflicts arise
5. **Prefer high ports** (8000+) for custom services to avoid system conflicts
