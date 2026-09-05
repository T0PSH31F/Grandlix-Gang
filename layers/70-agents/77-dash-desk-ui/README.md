# Tier 77 — Dashboard & Desktop UI (`77-dash-desk-ui`)

## Tier Purpose

The `77-dash-desk-ui` tier is responsible for end-user web applications, desktop chat dashboards, and interactive LLM web UIs. It contains frontends such as Open WebUI, Ollama-UI, and SillyTavern. Autonomous agent backends (71-harness), multi-agent orchestrators (76-orchestrators), and raw model inference servers (74-ai-infra) do NOT belong here.

## Module Registry

| Module | Description | Option Path | Default Port(s) | Service Type | Enabling Tag(s) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `ollama-ui.nix` | Minimal web interface for local Ollama instances. | `services.ai-services.ollama-ui` | 8087 | Always-on systemd service | `desktop`, `workstation`, `homelab` |
| `open-webui.nix` | Full-featured chat & RAG user interface supporting multi-user LLM interactions. | `services.ai-services.open-webui` | 8088 | Always-on systemd service | `desktop`, `workstation`, `homelab` |
| `sillytavern.nix` | SillyTavern interactive LLM chat and character frontend interface. | `services.sillytavern-app` / `clan.services.ai.sillytavern` | 8000 | Always-on systemd service | `desktop`, `workstation`, `homelab` |

## Tier Relationships

- **Frontends to Routers & Inference**: `77-dash-desk-ui` applications connect to local inference backends in `74-ai-infra` (Ollama `:11434`) or router proxies in `78-llm-routers` (Kong Gateway `:8090`, ExtremeRouter `:20128`).
- **Desktop Shell Integration**: Accessible directly via browser or web app shortcuts in `40-desktop` / `60-gui-programs`.
