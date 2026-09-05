# Tier 73 — Memory (`73-memory`)

## Tier Purpose

The `73-memory` tier provides long-term agent memory, Personal Knowledge Base (PKB) RAG APIs, context distillation, memory governance, and telemetry observability. It contains services like Brain-service, ContextForge, EverOS, Gno, Honcho, Langfuse, Memory Vault, and Memory Governance. raw LLM inference backends (74-ai-infra), interactive execution harnesses (71-harness), and raw vector databases (25-data) do NOT belong here.

## Module Registry

| Module | Description | Option Path | Default Port(s) | Service Type | Enabling Tag(s) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `brain-service.nix` | PKB RAG service — ingestion, indexing, and vector query API for notes/documents. | `services.ai-services.brain-service` | 8010 | Always-on systemd service | `pkb-node`, `ai-server`, `homelab` |
| `context-forge.nix` | ContextForge agent prompt assembly & dynamic context window manager. | `layers.layer-73.memory.context-forge` / `services.ai-services.context-forge` | 8094 | Always-on systemd service | `pkb-node`, `ai-agent`, `homelab` |
| `everos.nix` | EverOS long-term memory consolidation & dream-cycle background engine. | `layers.layer-73.memory.everos` | 8092 | Always-on systemd service | `pkb-node`, `ai-agent`, `homelab` |
| `gno.nix` | GNO (Gnosis Knowledge Node) graph-based knowledge lookup daemon. | `layers.layer-73.memory.gno` | 3456 | Always-on systemd service | `pkb-node`, `homelab` |
| `honcho.nix` | Honcho user profile & memory state engine (containerized API, deriver, Redis). | `services.honcho` | 8000 (Internal) | Always-on OCI container service | `pkb-node`, `ai-agent`, `homelab` |
| `langfuse.nix` | Langfuse LLM observability, prompt management, and trace telemetry suite. | `services.infrastructure.langfuse` | 3000 | Always-on OCI container service | `pkb-node`, `homelab` |
| `memory-governance.nix` | Swarm memory governance, privacy filters, and policy enforcement daemon. | `layers.layer-73.memory.memory-governance` | None | Always-on systemd service | `pkb-node`, `ai-agent` |
| `memory-vault.nix` | Memory Vault encrypted key-value store and memory snapshot manager. | `layers.layer-73.memory.memory-vault` | 8093 | Always-on systemd service | `pkb-node`, `ai-agent` |

## Tier Relationships

- **Data Layer Backend**: `73-memory` services persist vector embeddings and relational schemas in `25-data` databases (PostgreSQL, Qdrant, ChromaDB).
- **Consumer Interfaces**: `73-memory` APIs (Brain-service `:8010`, EverOS `:8092`, ContextForge `:8094`) are consumed by agent harnesses in `71-harness` (Hermes, OpenCode, Antigravity) and orchestrators in `76-orchestrators` via HTTP REST and MCP tools in `75-mcp`.
