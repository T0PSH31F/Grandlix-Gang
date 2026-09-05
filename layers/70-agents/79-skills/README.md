# Tier 79 — Skills & Extensions Catch-all (`79-skills`)

## Tier Purpose

The `79-skills` tier is responsible for agent skill catalogs, AI package bundles, agent task execution integrations, and cross-tier meta-options. It houses `ai-packages`, `ai-services` meta-declarations, `llm-agents`, `llm-agents-catalog`, and `todo-system`. Core runtime engines, standalone routers, and dedicated memory databases do NOT belong here.

## Module Registry

| Module | Description | Option Path | Default Port(s) | Service Type | Enabling Tag(s) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `ai-packages.nix` | System-wide package collection for AI CLI utilities, PyTorch/Python helpers, and tool binaries. | `layers.layer-79.skills.ai-packages` | None | System package bundle | `ai-agent`, `development`, `workstation` |
| `ai-services.nix` | Master top-level option namespace defining default `services.ai-services.*` flags. | `services.ai-services` | None | Meta-option registry | `ai-agent`, `ai-router`, `ai-server` |
| `llm-agents.nix` | Flake integration for `llm-agents.nix` packages and helper bindings. | `services.llm-agents` | None | Package bundle wrapper | `ai-agent`, `development` |
| `llm-agents-catalog.nix` | Declarative catalog of available agent skills, prompt templates, and tool manifests. | `layers.layer-79.skills.llm-agents-catalog` | None | Catalog registry | `ai-agent`, `development` |
| `todo-system.nix` | Agent task tracking system — Rofi frontend, Hermes roundups, and periodic timers. | `layers.layer-79.skills.todo-system` | None | User systemd timers & TUI | `ai-agent`, `desktop` |

## Tier Relationships

- **Meta-Declarations for All Tiers**: `ai-services.nix` and `ai-packages.nix` declare the base options consumed by services in `71-harness` through `78-llm-routers`.
- **Agent Skill Supply**: `llm-agents-catalog.nix` supplies skill definitions to agent harnesses in `71-harness` (OpenCode, Hermes) and `75-mcp`.
