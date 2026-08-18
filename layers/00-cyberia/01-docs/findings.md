# Findings & Decisions: July 26, 2026

## Additions

### 1. Mission Control (`builderz-labs/mission-control`)
- **What:** Self-hosted AI agent control plane — task dispatch, run review, spend tracking, fleet coordination
- **Stack:** Next.js 16, React 19, TypeScript, SQLite, Docker
- **Approach:** OCI container via `virtualisation.oci-containers`
- **Module:** `layers/20-services/22-ai/mission-control.nix`
- **Image:** `ghcr.io/builderz-labs/mission-control:latest`
- **Port:** 3000 (configurable)
- **Data:** `/var/lib/mission-control`
- **Enabled by:** `services.ai-services.mission-control.enable = true` (opt-in, default false)
- **Not yet enabled on any machine** — needs explicit enable in `machines/luffy/default.nix` or `machines/z0r0/default.nix`

### 2. Herm TUI (`liftaris/herm`)
- **What:** Hermes TUI built with OpenTUI — operator-focused dashboard for Hermes Agent
- **Stack:** TypeScript, Bun, OpenTUI
- **Approach:** Built from GitHub source via `buildNpmPackage`, added to home.packages
- **Module:** `layers/70-agents/77-herm/` (default.nix + herm.nix)
- **Enabled by:** `layers.layer-77.herm.enable = true` (default true via `ai-agent` tag)
- **Source hash and npmDepsHash are placeholders** — will fail first build; replace with real hashes from build error output
- Registered in `layers/70-agents/default.nix` and `layers/90-profiles/tags/ai-agent.nix`

### 3. AionUi (`iOfficeAI/AionUi`)
- **What:** Free, open-source Cowork app with AI agents — web UI for Hermes Agent, Claude Code, Codex, etc.
- **Stack:** TypeScript, Bun, pre-built ELF binary (v2.1.41)
- **Approach:** Downloads `aionui-web-*.tar.gz` release binary, runs as systemd service
- **Module:** `layers/20-services/22-ai/aionui.nix`
- **Port:** 3001 (3000 taken by Mission Control)
- **Data:** `/var/lib/aionui`
- **Enabled by:** `services.ai-services.aionui.enable = true` (opt-in, default false)

## Files Changed
| File | Action |
|------|--------|
| `layers/20-services/22-ai/mission-control.nix` | Created |
| `layers/20-services/22-ai/default.nix` | Modified (added import) |
| `layers/20-services/22-ai/ai-services.nix` | Modified (added default enable) |
| `layers/70-agents/77-herm/default.nix` | Created |
| `layers/70-agents/77-herm/herm.nix` | Created |
| `layers/70-agents/default.nix` | Modified (added ./77-herm import) |
| `layers/90-profiles/tags/ai-agent.nix` | Modified (added layer-77.herm enable) |

## Next Steps
1. ~~Rebuild to get real hashes for Herm (`sha256` + `npmDepsHash`)~~
2. ~~Decide which machine gets Mission Control (suggest luffy — 24/7 server)~~ → Done: luffy gets `ai-agent` tag (2026-07-29)
3. ~~If on luffy: add Caddy reverse-proxy entry + enable in `machines/luffy/default.nix`~~ → Done: `mission-control.lovelain.duckdns.org` → `localhost:3099`
4. Link in progress.md + AGENTS.md

## Changes (2026-07-29): Fleet Agent Mesh

### Mission Control + Hermes Fleet
- **Decision:** luffy (24/7 server) runs Mission Control as the fleet's agent control plane
- **Tag:** Added `"ai-agent"` to luffy's machine tags in `clan.nix` — enables full Hermes stack: hermes-agent, hermes-webui, hermes-dashboard, herm TUI, open-skills, Mission Control, AionUi, Paperclip
- **Firewall:** Port 3099 opened on luffy for Mission Control
- **Caddy:** `mission-control.lovelain.duckdns.org` → `localhost:3099` reverse proxy

### Fleet Architecture
```
z0r0 (laptop)                     luffy (server 24/7)
├── Hermes Agent                  ├── Hermes Agent
├── Herm TUI                      ├── Herm TUI
├── Hermes Dashboard :9119        ├── Hermes Dashboard :9119
├── Hermes WebUI :3000            ├── Hermes WebUI :3000
├── OpenCode / Claude Code        ├── OpenCode / Claude Code
│                                 │
└── Matrix Gateway ───────────────┤  Matrix Synapse :8008
    (connects to luffy)           │  (all agents chat here)
                                  │
                                  ├── Mission Control :3099
                                  │   (fleet control plane)
                                  ├── AionUi :3001
                                  └── Paperclip
```

### Inter-Agent Communication
- **Matrix:** Both z0r0 and luffy Hermes instances use Matrix gateway (`@hermes:matrix.local`) on luffy's Synapse. Agents communicate in Matrix rooms.
- **Mission Control:** Web UI at `mission-control.lovelain.duckdns.org` for fleet-wide task dispatch, run review, spend tracking.
- **AionUi:** Web UI at port 3001 for agent co-working.
- **Hermes API Server:** Both instances bind to `0.0.0.0` — callable across Tailscale network with token auth.

## Issues
- Herm source hash is a placeholder — the agent cannot compute npm dependency hashes without a build attempt
- Mission Control requires first-run setup at `http://<host>:3000/setup`
- AionUi uses a pre-built binary — tarball hash is a placeholder; replace on first build
- ⚠ Port conflict potential: Mission Control (3000) vs AionUi (3001) — verify both are unique
