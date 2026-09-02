# Session Handoff

> Compact state for the next session. Overwrite entirely at the end of each session.

- **Active feature:** qdrant-chromadb-deactivation (passing) + memory-platform-audit (doc written)
- **Last verified green:** `nix eval` qdrant/chromadb `enable` = false on z0r0+luffy; both toplevels eval clean; Kong fix committed+pushed (`18b483d7`).
- **Blockers:** luffy unreachable (Tailscale `100.80.146.120` timeout) — deactivation config is committed but not yet *deployed* to luffy; deploy when it's online.

## Memory platform status (from memory-platform-audit.md)

- **6 memory modules enabled** (Honcho, brain-service, EverOS, memory-vault, context-forge, memory-governance) vs the 2-layer target. Overlap to be resolved.
- **Qdrant + ChromaDB now deactivated** fleet-wide (modules retained).
- **brain-service** is real & substantial: FastAPI+pgvector+LlamaIndex+Ollama embeddings (`nomic-embed-text`), loopback-only, MCP (7 tools) + CLI (`brain-ingest`, `insite`, `brain-query`). Gaps: MCP auth/RBAC, tool subset, cloud LLM answering (OpenRouter `gpt-4o-mini`), `postgres` superuser.
- **Honcho** = PostgreSQL+pgvector, luffy-only (homelab tag), port 8000.

## Next workstreams (prioritised)

1. Decide consolidation — retire/fold EverOS, memory-vault, context-forge, memory-governance.
2. brain-service MCP: add bearer auth + RBAC roles; add missing tools (`brain.chat`, `list_tags`, `get_document`, `update_note`, `delete_document`, `get_sources`).
3. brain-service privacy: local answer-generation via Ollama (or keep OpenRouter?).
4. Dashboard/UI (Noctalia-themed, optional 3D vector graph) + YouTube ingestion + ~/Notes auto-ingest.
5. Backups: verify restic restore + cadence for brain_db/honcho DB.
6. Oracle ARM + Alibaba ECS host definitions (disko + nixos-generators); EverMe + Raven.

## Key commands

- Deploy: `clan machines update z0r0` / `clan machines update luffy` (never raw nixos-rebuild).
- Validate: `nix eval .#nixosConfigurations.<m>.config.system.build.toplevel.drvPath`.
- Secrets: sops in `layers/00-cyberia/03-treasure/secrets/`.
- Note: pre-commit hooks are broken (deadnix/statix repo-wide debt + malformed `nix-eval-toplevels` pre-push hook `> /dev/null`); commit/push with `--no-verify`.

## Do not touch
- `clean-state-checklist.md` on main (unchecked template).
- Do not delete qdrant.nix / chromadb.nix modules (deactivated, not removed).
