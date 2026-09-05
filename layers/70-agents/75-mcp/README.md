# Tier 75 — Model Context Protocol (`75-mcp`)

## Tier Purpose

The `75-mcp` tier is responsible for Model Context Protocol (MCP) server integration, tool server discovery, MCP catalog declarations, and MCP middleware proxies (such as Headroom and Mistral MCP). It allows AI agents and harnesses to securely invoke external tools, filesystem operations, and database adapters. Direct agent CLI binaries (71-harness) and raw LLM inference endpoints (74-ai-infra) do NOT belong here.

## Module Registry

| Module | Description | Option Path | Default Port(s) | Service Type | Enabling Tag(s) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `server-catalog.nix` | Declarative MCP server catalog, registering filesystem, GitHub, Postgres, and web search servers. | `layers.layer-75.mcp` | None | Declarative config generator | `ai-agent`, `workstation`, `desktop` |
| `mcp.nix` | Legacy options bridge forwarding older `layers.layer-70.agent.mcp` settings to `layer-75`. | `layers.layer-70.agent.mcp` | None | Configuration bridge | `ai-agent` |
| `headroom.nix` | Headroom MCP context optimizer & prompt compression proxy server. | `services.ai-services.headroom` | 8095 | Always-on systemd service | `ai-agent`, `homelab` |
| `mistral-mcp.nix` | Mistral MCP service daemon exposing Mistral model capabilities via MCP tool definitions. | `services.ai-services.mistral-mcp` | 8096 | Always-on systemd service | `ai-agent`, `homelab` |

## Tier Relationships

- **Consumed by Harnesses**: MCP server definitions from `server-catalog.nix` are imported and exposed to agent harnesses in `71-harness` (OpenCode, Hermes, Antigravity) via `~/.config/opencode/mcp.json` and Hermes tool registries.
- **Connects to Services & Memory**: MCP tool adapters interface with databases in `25-data` and memory services in `73-memory` (Brain-service, ContextForge).
