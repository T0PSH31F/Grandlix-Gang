# Session Handoff

> Compact state for the next session. Overwrite entirely at the end of each session.

- **Active feature:** Tag refactor — granular service redistribution across z0r0/luffy/sanji
- **Last verified green:** `nix eval` toplevel on z0r0, luffy, sanji all pass; `dendritic-structure-test` passes.
- **Blockers:** luffy has sudo back but Tailscale is not responding (needs recovery — see below).

## Tag refactor summary (completed this session)

### New tags created
- **`ai-router`** — LLM routing/gateway (Kong, Omniroute, FreellmAPI, FreellmPool, postgresql)
- **`pkb-node`** — Personal knowledge base (brain-service, Honcho, langfuse, monitoring, backups)
- **`agent-orchestrator`** — Agent control-plane (Hermes server, MCP, sandbox, Mission Control, Paperclip, AionUI)
- **`network-router`** — Network control-plane (Homepage dashboard, Headscale, Tailscale)

### Machine → Tag mapping
- **z0r0** (desktop workstation): `desktop`, `workstation`, `laptop`, `development`, `gaming`, `intel-12th-gen` — no always-on server services; ExtremeRouter enabled directly in machine config
- **luffy** (homelab server): `server`, `homelab`, `ai-agent`, `pkb-node`, `cache-server`, `media`, `intel-9th-gen` — private memory (brain-service, Honcho), Matrix, n8n, media
- **sanji** (cloud control-plane): `server`, `homelab`, `network-router`, `ai-router`, `agent-orchestrator` — always-on AI gateway, agent orchestration, homepage, headscale

### Files changed
- `clan.nix` — new tag assignments for all 3 machines
- `layers/90-profiles/tags/ai-router.nix` — created
- `layers/90-profiles/tags/pkb-node.nix` — created/fixed (langfuse path corrected to `services.infrastructure.langfuse`)
- `layers/90-profiles/tags/agent-orchestrator.nix` — created/fixed (removed nonexistent `layer-70.agent.enable`, `hermes-desktop`)
- `layers/90-profiles/tags/network-router.nix` — created
- `layers/90-profiles/tags/ai-server.nix` — stripped to minimal postgresql dep (deprecated)
- `layers/90-profiles/tags/homelab.nix` — removed headscale (moved to network-router)
- `layers/90-profiles/tags/default.nix` — added new tags to validTags registry
- `layers/00-cyberia/05-tests/dendritic-structure-test.nix` — updated validTags to match
- `machines/z0r0/default.nix` — removed stale mkForce overrides (jan, aider, llama-swap duplicate, langfuse container ref, Homepage dashboard)
- `machines/luffy/default.nix` — removed stale `jerry` package reference
- `layers/60-gui-programs/62-media/packages-media.nix` — removed undefined `jerry` package

### mkForce audit
- `mkForce false` kept on z0r0 for services with `enable = true` module defaults (ollama, open-webui, chromadb, llama-cpp-server, llama-swap, wyoming-services, localai) — these need upstream fix to `mkDefault false` to eliminate
- `mkForce false` on kong-gateway, freellmpool, polyfloor in z0r0 can be removed once tags are stable (they use mkEnableOption, default false)

## Luffy Tailscale recovery (IN PROGRESS)

User has sudo back. Tailscale not responding. Suggested:
```bash
rm -f /var/run/tailscale/tailscaled.sock
systemctl restart tailscaled
sleep 2
tailscale up --login-server=https://headscale.lovelain.duckdns.org
```
If tailscaled state was wiped by impermanence, re-auth from scratch.

## Next workstreams

1. **Luffy Tailscale recovery** — user working on this now
2. **Fleet deployment** — `clan machines update sanji` (first deploy to new VPS)
3. **upstream mkForce cleanup** — change module defaults (ollama, open-webui, etc.) from `enable = true` to `mkDefault false` to eliminate machine-level mkForce overrides
4. **Omniroute port config** — confirm sanji's Omniroute listens on 20128 (no conflict with z0r0's ExtremeRouter, different machines)
5. **Backup verification** — restic restore drill for brain_db on luffy
6. **ORACLE/Alibaba ARM** — additional VPS hosts

## Key commands
- Deploy: `clan machines update z0r0` / `clan machines update luffy` / `clan machines update sanji`
- Validate: `nix eval .#nixosConfigurations.<m>.config.system.build.toplevel.drvPath`
- Secrets: sops in `layers/00-cyberia/03-treasure/secrets/`

## Do not touch
- `clean-state-checklist.md` on main (unchecked template).
- Do not delete qdrant.nix / chromadb.nix modules (deactivated, not removed).
- Do not delete ai-server.nix tag file (deprecated but may still be referenced).
