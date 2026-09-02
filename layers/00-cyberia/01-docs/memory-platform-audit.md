# Memory Platform Audit

> Status: 2026-09-01 · Evidence-backed audit of the NFP agentic memory stack against
> the target two-layer architecture (Honcho = durable profile memory, brain-service =
> knowledge/corpus memory). This document records what exists, what is broken, and
> what is missing so subsequent workstreams have a verifiable baseline.

## Target vs. actual

The consolidated target is **two memory layers**:

1. **Honcho** — durable agent/user profile memory (preferences, interaction history, decisions).
2. **brain-service** — knowledge memory (corpus: books, PDFs, web links, bookmarks, MD notes),
   on PostgreSQL + pgvector + LlamaIndex, exposed via MCP.

Reality: **six** memory modules are currently enabled, an overlapping stack that the target
wants to collapse to two.

## Enabled memory stack (verified from module + tag sources)

Both `z0r0` and `luffy` carry the `ai-server` and `ai-agent` tags (`clan.nix` inventory).
`luffy` additionally carries `homelab`. Consequently:

| Module | Enable source | Hosts | Port | Backing store |
|---|---|---|---|---|
| Honcho | `homelab` tag (luffy only) | luffy | 8000 | PostgreSQL + pgvector |
| brain-service | `ai-server` tag | both | 8010 | PostgreSQL + pgvector + LlamaIndex, Ollama embeddings (`nomic-embed-text`, 768d) |
| EverOS | `ai-agent` tag | both | 8092 | EverOS server (nightly consolidation timer) |
| memory-vault | `ai-agent` tag | both | — | git-mesh vault under `/var/lib/memory/vault` (15-min sync) |
| context-forge | `ai-agent` + `ai-server` tag | both | 8094 | MCP gateway + agent scoping |
| memory-governance | `ai-agent` + `ai-server` tag | both | — | ACL over shared/private stores |
| **Qdrant** | — | **none** | 6333 | **deactivated this session** (was `mkDefault false`; stale luffy reverseProxy route removed) |
| **ChromaDB** | — | **none** | 8004 | **deactivated this session** (was `mkDefault true` on luffy) |

## What works (verified)

- **brain-service** is a real, substantial module: FastAPI + LlamaIndex + pgvector,
  `pymupdf`/`ebooklib`/`beautifulsoup4` parsing, Ollama local embeddings, a `watchdog`
  file watcher, an MCP server, and CLI tools (`brain-ingest`, `insite`, `brain-query`).
  Bindings are loopback-only (`HOST=127.0.0.1`) — good for privacy.
- **Honcho** uses PostgreSQL + `pgvector` extension (`services.postgresql.extensions = [pgvector]`),
  with its own `honcho` DB/user. Local by default.
- **pgvector** is available (`postgresql-vectordb.nix`, honcho.nix, brain-service.nix).

## Gaps vs. the target brief (what is missing / wrong)

1. **Qdrant + ChromaDB deactivation** — ✅ DONE this session (both now `false` on z0r0+luffy;
   modules retained; stale `qdrant = 6333` reverseProxy route removed from luffy).
   Verification: `nix eval .#nixosConfigurations.{z0r0,luffy}.config.services.ai-services.{qdrant,chromadb}.enable` → all `false`; both toplevels eval clean.
   Remaining cleanup (non-blocking): homepage-dashboard still renders Qdrant/ChromaDB
   widget cards (lines 115/119/265/266) — they'll simply show "down".
2. **brain-service MCP tool set is a subset** of the brief's list. Implemented:
   `brain_query`, `brain_remember`, `brain_ingest_book`, `brain_ingest_directory`,
   `brain_list_books`, `brain_frequent_queries`, `brain_auto_remember`. Missing:
   `brain.chat`, `brain.list_tags`, `brain.get_document`, `brain.update_note`,
   `brain.delete_document`, `brain.get_sources`, and YouTube ingestion.
3. **No MCP authentication/RBAC.** The MCP server is plain stdio with no bearer-token
   gate and no reader/writer/admin roles (brief explicitly asked for this).
4. **brain-service LLM answering is cloud**: `llmApiBase` defaults to
   `https://openrouter.ai/api/v1` with `gpt-4o-mini`. Embeddings are local (Ollama) but
   answer generation leaves the box — conflicts with the "as private as possible" requirement.
   (OpenRouter key is already wired via clan var `brain-service` env generator.)
5. **DB user hardening**: brain-service connects as the `postgres` superuser and DB
   `vectordb`; brief wants a dedicated `brain_user` / `brain_db`. Honcho already uses its own user.
6. **Six overlapping memory modules** (Honcho, brain-service, EverOS, memory-vault,
   context-forge, memory-governance) — not yet consolidated to two. EverOS/context-forge/
   memory-vault are enabled on BOTH machines, duplicating memory stores.
7. **No dashboard/UI** for browse/ingest/note-edit/tag-management/chat (brief §7).
   No 3D vector-graph view. No Noctalia theming. No YouTube ingestion/playlist polling.
8. **Backups**: `restic-backups.nix` exists (Google Drive + teldrive, PostgreSQL pre-dump
   `pg_dumpall`), but a tested restore + the specific "daily incremental / weekly full /
   monthly archive" cadence and brain-service/honcho-specific dump coverage is unverified.
9. **Oracle ARM / disko / nixos-generators**: `disko` and `nixos-generators` hooks exist in
   the flake (iso templates under `layers/00-cyberia/04-templates`, `08-iso`), but no
   Oracle/Alibaba host definition or aarch64 image is present. Alibaba ECS is future work.
10. **EverMe + Raven**: not present; future additions.

## Memory-tool vetting (verified by reading the repos, 2026-09-01)

`web_search` is currently broken (invalid harness search-key), so these were read
directly via `git clone` of the upstream repos.

- **Our `everos.nix` is NOT EverOS.** It is a ~200-line FastAPI stub that does
  naive substring grep over a Markdown vault into a JSON index (0 embedding/pgvector
  references). It should be retired — it is strictly worse than brain-service.
- **Real EverOS** (`EverMind-AI/EverOS`): a Python local-first memory engine —
  Markdown source-of-truth + SQLite + LanceDB, user "episodes/profile" + agent
  "cases/skills". Serious, embeddable, but a *third* memory substrate. Defer.
- **EverMe** (`EverMind-AI/EverMe`): **only a client toolchain** (CLI + MCP +
  agent plugins). Its backend is the hosted `evermind.ai` cloud service (or a
  self-hosted EverOS via `EVERME_API_BASE`). Skip — the hosted path violates the
  "as private as possible" requirement.
- **gno** (`gmickel/gno`): local knowledge engine — hybrid search (BM25+vector),
  workspace with graph + editor, verified answers with citations, egress policy
  (`local_only`/`lan`/`remote`), MIT, no telemetry, no GPU. **Strong candidate**
  for the retrieval/workspace/graph layer (covers dashboard + 3D graph + citation
  goals privately).

## Progress log

- **2026-09-01 (workstream 1 + consolidation):** brain-service MCP bearer auth +
  RBAC (reader/writer/admin) + 8 new tools implemented and deployed to z0r0 (new
  `/tags`, `/documents` endpoints return 200). EverOS + context-forge retired
  (eval false on z0r0+luffy); memory-vault retained.
  **Runtime finding:** brain-service is enabled on z0r0 but its embedding backend
  (Ollama, `nomic-embed-text`) is `inactive` on z0r0 (`ollama.enable = mkForce false`
  in machines/z0r0/default.nix). Consequence: ingest/remember/query fail on z0r0.
  Placement fix = brain-service should run on **luffy** (where ollama runs), not z0r0.

## Open questions for the owner (blocking for later workstreams)

- Which of EverOS / memory-vault / context-forge / memory-governance should be retired
  vs. folded into Honcho+brain-service? (Brief says collapse to two, but these four are enabled.)
- Should brain-service answer-generation stay cloud (OpenRouter) or move to a local model
  via Ollama for privacy?
- Confirm luffy is the single memory host (both machines currently enable brain-service/
  EverOS/etc. via shared tags) — deactivation/placement needs per-machine overrides.
