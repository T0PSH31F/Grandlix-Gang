# Machine × Tag Matrix (`tag-matrix.md`)

## Matrix Table

The table below maps every machine (`z0r0`, `luffy`, `sanji`, `T14`) against all 18 valid tags in `layers/90-profiles/tags/default.nix`.

`[X]` indicates the tag is enabled for the machine; `[ ]` indicates it is omitted.

| Tag | `z0r0` | `luffy` | `sanji` | `T14` | Assignment Rationale |
| :--- | :---: | :---: | :---: | :---: | :--- |
| `ai-agent` | `[X]` | `[X]` | `[ ]` | `[X]` | Enabled on client interactive nodes (z0r0, T14) and luffy background workers for OpenCode/Hermes agent execution. Omitted on sanji to keep cloud VPS lean. |
| `ai-router` | `[ ]` | `[ ]` | `[X]` | `[ ]` | Enabled strictly on sanji as the cloud control-plane API gateway (Kong, ExtremeRouter, FreeLLMAPI, Manifest). Omitted on z0r0/luffy to prevent router duplication. |
| `ai-server` | `[ ]` | `[X]` | `[ ]` | `[ ]` | Enabled on luffy as the local inference and memory host (Brain-service, Ollama, EverOS). Omitted on z0r0 to prevent daily-driver RAM thrashing. |
| `agent-orchestrator` | `[ ]` | `[ ]` | `[X]` | `[ ]` | Enabled on sanji as the central swarm orchestrator (Polyfloor, Paperclip, Mission Control, AionUI). Omitted on z0r0/luffy. |
| `cache-server` | `[ ]` | `[X]` | `[ ]` | `[ ]` | Enabled on luffy to host the Harmonia Nix binary cache server for the local network. |
| `desktop` | `[X]` | `[ ]` | `[ ]` | `[X]` | Enabled on z0r0 and T14 for Wayland (Hyprland/Niri), PipeWire audio, GUI apps, and desktop environment shells (Noctalia). Omitted on headless servers. |
| `development` | `[X]` | `[ ]` | `[ ]` | `[X]` | Enabled on workstation clients for developer CLI tools, compilers, IDEs, and SDKs. Omitted on production servers. |
| `gaming` | `[X]` | `[ ]` | `[ ]` | `[ ]` | Enabled exclusively on z0r0 for Steam, GameMode, Lutris, and graphics drivers. |
| `gpu-compute` | `[ ]` | `[X]` | `[ ]` | `[ ]` | Enabled on luffy for hardware-accelerated local model execution (Ollama, llama.cpp, vLLM). |
| `homelab` | `[ ]` | `[X]` | `[X]` | `[ ]` | Enabled on servers (luffy, sanji) to run containerized services, background daemons, and storage. |
| `intel-12th-gen` | `[X]` | `[ ]` | `[ ]` | `[X]` | Enabled on 13th/12th gen Intel mobile processors (z0r0, T14) for i915 PSR fix and power management. |
| `intel-9th-gen` | `[ ]` | `[X]` | `[ ]` | `[ ]` | Enabled on luffy for 9th gen Intel CPU power/thermal microcode tuning. |
| `laptop` | `[X]` | `[ ]` | `[ ]` | `[X]` | Enabled on portable battery-powered machines (z0r0, T14) for TLP, backlight, and power profile management. |
| `media` | `[ ]` | `[X]` | `[ ]` | `[ ]` | Enabled exclusively on luffy to run media servers (Jellyfin, *arr stack, Kavita). |
| `network-router` | `[ ]` | `[ ]` | `[X]` | `[ ]` | Enabled on sanji for Tailscale / Headscale mesh VPN routing and cloud packet forwarding. |
| `pkb-node` | `[ ]` | `[X]` | `[ ]` | `[ ]` | Enabled on luffy as the sole encrypted PKB vault and RAG vector storage host. Omitted on z0r0/sanji to guarantee notes privacy and zero RAM bloat. |
| `server` | `[ ]` | `[X]` | `[X]` | `[ ]` | Enabled on headless server hosts (luffy, sanji) for systemd server defaults, SSH hardening, and headless boot. |
| `workstation` | `[X]` | `[ ]` | `[ ]` | `[X]` | Enabled on primary developer workstation machines (z0r0, T14) for developer desktop tooling. |

---

## Key Design Rationale

### Why `z0r0` has NO `pkb-node` or `ai-server`:
`z0r0` is a 16 GB RAM LG Gram daily driver. Running heavy vector databases, RAG embedding models, and memory servers locally peed memory usage to 100% and caused severe swap thrashing. Offloading PKB and AI inference to `luffy` converts `z0r0` into a crisp, responsive thin-client harness.

### Why `sanji` has NO `ai-inference` or `pkb-node`:
`sanji` is a cloud VPS (2 vCPU / 16 GB). Private knowledge notes must never leave the home network (kept on `luffy`), and GPU/heavy LLM inference is too costly on cloud vCPUs. `sanji` serves strictly as an HTTP/API edge router (`ai-router`) and fleet orchestrator (`agent-orchestrator`).
