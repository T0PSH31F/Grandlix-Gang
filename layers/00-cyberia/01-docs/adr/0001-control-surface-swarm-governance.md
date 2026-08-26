# ADR-0001: NFP Control Surface & Agent Swarm Governance Architecture

- **Status**: Accepted
- **Date**: 2026-08-26
- **Authors**: NFP AI Agent Fleet Architecture Team
- **Targets**: `z0r0` (workstation/desktop), `luffy` (homelab/AI control plane)

---

## 1. Context & Problem Statement

The NFP (Nix Flake Pirates) fleet runs an autonomous multi-agent swarm ecosystem composed of diverse agent runtimes (`hermes`, `opencode`, `claude-code`, `codex`, `cursor`, `deerflow`, `polyfloor`, `paperclip`, `opencompany`, `dsh`).

Without centralized governance:
- Agents share generic API keys, preventing fine-grained usage tracking, per-agent rate limits, and metric isolation.
- Agent memory access lacks policy enforcement, raising privacy risks between public shared memory and private workspace context.
- Untrusted code execution by coding agents risks host filesystem contamination or unauthorized network access.

---

## 2. Decision Outcome

We adopt a 5-pillar **Control Surface & Swarm Governance Architecture**:

### Pillar 1: Kong AI Gateway Consumer Isolation (`kong-consumer-per-agent`)
- Every agent runtime is assigned a dedicated Kong consumer (`hermes`, `opencode`, `claude-code`, `codex`, `cursor`, `deerflow`, `polyfloor`, `paperclip`, `opencompany`, `dsh`).
- Authentication is enforced via `key-auth` with per-consumer rate limiting (120 req/min, 2000 req/hr) and Prometheus metrics.
- SOPS templates generate per-consumer key credentials, eliminating hardcoded keys across the flake.

### Pillar 2: Polyfloor Multi-Floor Agent OS (`polyfloor-registry`)
- Polyfloor acts as the organization registry and workspace coordinator.
- Integrated into `layers/20-services/22-ai/25-harness-control/polyfloor.nix`, utilizing NFP's shared PostgreSQL instance and endpoints registry (`endpoints.nix`).
- Persistent state lives under `/var/lib/polyfloor` with impermanence support.

### Pillar 3: Container & Sandbox Isolation (`agent-sandbox-images`)
- Untrusted agent execution runs inside isolated sandbox containers managed by `layers/70-agents/74-ai-infra/agent-sandbox.nix`.
- Supported backends include Podman and Bubblewrap with read-only root filesystems, ephemeral `/tmp` tmpfs mounts, and configurable network policies (`restricted`, `none`, `host`).

### Pillar 4: Memory Governance Plane (`memory-governance-plane`)
- Memory access is partitioned into **Shared** (`/var/lib/memory/vault`) and **Agent-Private** (`/var/lib/hermes/`, `/var/lib/opencode/`) scopes.
- Policy enforcement is executed via ContextForge MCP gateway (`port 8094`) and EverOS engine (`port 8092`).
- Sandboxed agents receive `shared-only` scope; primary agents (Hermes) receive `shared + private` scopes.

### Pillar 5: Declarative Flake Integration & Machine Update Workflow
- All governance configurations are defined declaratively in `layers/`.
- Machine updates are deployed exclusively via `clan machines update z0r0` / `clan machines update luffy`.

---

## 3. Verification & Compliance
- **Flake Evaluation**: Evaluated cleanly on `z0r0` and `luffy` toplevel targets.
- **Port Registry**: Registered and validated against port collision assertions in `endpoints.nix`.
- **Harness Tracking**: Verified via evidence logs in `feature_list.json`.
