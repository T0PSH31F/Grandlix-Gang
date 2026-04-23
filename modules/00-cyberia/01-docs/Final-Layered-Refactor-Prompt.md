# NFP Dendritic Architecture Migration

> Structural refactor of the NFP repository to a **Dendritic Architecture** —
> a hierarchically-numbered module tree with unified multi-class modules,
> `import-tree` auto-discovery, and tag-based profile composition via clan-core.

---

## Numbering System

All modules live under `/modules/` using a **tiered decimal hierarchy**:

- **Top tiers:** `10`, `20`, `30`, `40`, `50`, `60`, `90`
- **Sub-tiers:** first digit = parent (`12` = child of `10-system`)
- **Fine-grained:** three digits (`121` = child of `12-hardware`)
- **Leaf variants:** dot notation (`121.1` = variant within `121`)

Any path starting with `4` is desktop. Importing `40-desktop/41-hyprland/`
gives you the entire Hyprland environment.

---

## Tier Definitions

| Tier | Name | Purpose |
|------|------|---------|
| **00** | Cyberia | Infrastructure scaffolding — sops, assets, templates, tests, scripts, docs |
| **10** | System | Base OS, Nix settings, hardware (CPU/GPU/boot), packages |
| **20** | Services | System daemons — networking, AI, media, data, monitoring |
| **30** | Identity | User profiles, SSH keys, global theming |
| **40** | Desktop | Compositors (Hyprland, Niri), DE addons, portals |
| **50** | CLI | Terminal environment — shells, editors, tools, multiplexers |
| **60** | GUI | Graphical applications — browsers, media, dev tools |
| **70** | Agents | AI automation — coding agents, voice, MCP |
| **80** | Lib | Nix library — helpers, overlays, custom packages |
| **90** | Profiles | Composition layer — machines defined by tags importing above |

---

## Unified Multi-Class Module Pattern

Every `.nix` module (except entry points) uses a **multi-class structure**
that can configure NixOS, Home-Manager, and Darwin from a single file:

```nix
# Target State Example (Phase 11): modules/40-desktop/41-hyprland/default.nix
{ config, lib, pkgs, ... }: {
  # During phases 1-10, keep existing option names (e.g., config.desktop.hyprland.enable)
  # Only in Phase 11 will we migrate to this new `features.` schema.
  options.features.desktop.hyprland.enable =
    lib.mkEnableOption "Hyprland compositor";

  # NixOS-level configuration
  nixos = lib.mkIf config.features.desktop.hyprland.enable {
    programs.hyprland.enable = true;
    xdg.portal.wlr.enable = true;
  };

  # Home-Manager configuration (merged into user's HM)
  home = lib.mkIf config.features.desktop.hyprland.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      settings = { /* ... */ };
    };
  };
}
```

### Tag-Awareness Principle
Layer modules should be **tag-AGNOSTIC**. They expose `options.features.*.enable` toggles. Profile files (`90-profiles/tags/*.nix`) are the **ONLY** place where tags map to enable toggles. This keeps layers reusable and testable in isolation.

**Toggle pattern:** `features.<tier>.<name>.enable` for every module.
Features are only applied when explicitly enabled in a Profile or Machine config.

> **NOTE:** This requires a module wrapper in `lib/` that splits `nixos` and
> `home` attributes into their respective module systems. Implement this in
> `lib/mkDendriticModule.nix`.

---

## Integration Toolkit

| Tool | Role |
|------|------|
| **`import-tree`** | Auto-scans `/modules/` and exports as flake outputs |
| **`flake-parts`** | All logic remains compatible with flake-parts framework |
| **`clan-core`** | Machine inventory maps machines to tags in `90-profiles/` |

---

## Success Criteria

1. All existing functionality preserved — zero behavior changes
2. `nix flake check` passes cleanly
3. `z0r0` and `nami` build successfully (luffy preserved, build skipped — offline)
4. Clean, professional, portfolio-ready code quality
5. Git workflow followed exactly as specified
6. Explicit approval before merging to main

---

## FLAKE.NIX PRESERVATION REQUIREMENTS

> [!CAUTION]
> The `flake.nix` uses `flake-parts` + `clan-core`. Do NOT replace with raw `lib.nixosSystem`.
> Machines are defined in `clan.nix` → `machines.*` blocks. The `mkMachineFromTags`
> function should be integrated as an import helper within each `clan.machines.${name}`
> block, NOT by replacing the existing flake-parts scaffold.

**You MUST Preserve:**
- `flake-parts.lib.mkFlake` wrapper
- `clan-core.flakeModules.default` import
- `clan.pkgsForSystem` with overlays
- `flake.clan.modules` (custom clan services)
- `flake.homeConfigurations` (root@vps)
- `perSystem` (devShells, checks, ISO)

---

## Target Directory Structure

```
NFP/
├── flake.nix                                        # PRESERVED — flake-parts + clan-core
├── flake.lock                                       # Nix lock file
├── clan.nix                                         # UPDATED — uses mkMachineFromTags
├── inventory.json                                   # Clan auto-managed
├── .sops.yaml                                       # Sops config (references sops/ below)
├── .envrc / .gitignore / README.md                   # Standard repo scaffolding
│
├── machines/                                        # ⚠️ CLAN REQUIRED — host-specific overrides
│   ├── z0r0/                                        # Primary workstation
│   ├── nami/                                        # Laptop
│   └── luffy/                                       # GPU workstation (offline)
│
├── vars/                                            # ⚠️ CLAN REQUIRED — auto-managed by clan CLI
│   ├── per-machine/
│   └── shared/
│
├── clan-services/                                   # ⚠️ CLAN REQUIRED — custom clan service modules
│
├── modules/                                         # ══ DENDRITIC ARCHITECTURE ══
│   ├── 00-cyberia/                                  # ══ INFRASTRUCTURE SCAFFOLDING ══
│   │   ├── 01-docs/                                 # Architecture docs, ADRs, migration notes
│   │   ├── 02-assets/                               # Static assets (wallpapers, icons, etc.)
│   │   ├── 03-sops/                                 # Secrets management
│   │   │   ├── keys/                                # Age/GPG public keys
│   │   │   └── secrets/                             # Encrypted secret files
│   │   └── 04-treasure/                             # Sops machine keys & encrypted vaults
│   │       ├── sops/                                # Per-machine age keys, user keys
│   │       └── secrets/                             # Encrypted service credentials
│   │
│   ├── 10-system/                                   # ══ BASE OS & HARDWARE ══
│   │   ├── 11-foundation/                           # Core system config
│   │   │   ├── nix-settings.nix
│   │   │   ├── base.nix
│   │   │   ├── networking.nix
│   │   │   ├── caches.nix
│   │   │   ├── optimization.nix
│   │   │   ├── overlays.nix
│   │   │   ├── clan-lib.nix
│   │   │   ├── resource-limits.nix
│   │   │   ├── fonts.nix
│   │   │   └── nix-tools.nix                        # Nix ecosystem tools (nix-index, nix-ld, etc.)
│   │   ├── 12-hardware/                             # Hardware abstraction
│   │   │   ├── 12.1-cpu/                             # CPU platforms
│   │   │   │   ├── intel.nix
│   │   │   │   ├── intel-7th-gen.nix
│   │   │   │   └── intel-12th-gen.nix
│   │   │   ├── 12.2-gpu/                             # GPU drivers
│   │   │   │   ├── amd.nix
│   │   │   │   ├── nvidia.nix
│   │   │   │   └── nvidia-hybrid.nix
│   │   │   ├── 12.3-peripherals/                     # Input/output devices
│   │   │   │   ├── bluetooth.nix
│   │   │   │   ├── touchpad.nix
│   │   │   │   └── razer.nix
│   │   │   ├── 12.4-platform/                        # Platform profiles
│   │   │   │   ├── common.nix
│   │   │   │   ├── audio.nix
│   │   │   │   └── laptop.nix
│   │   ├── 13-packages/                             # Foundational package sets only
│   │   │   └── base.nix                             # Base system packages
│   │   ├── 14-virtualization/                       # Containers & VMs
│   │   │   └── virtualization.nix
│   │   ├── 15-storage/                              # Filesystem & persistence
│   │   │   └── impermanence.nix
│   │   ├── 16-mobile/                               # Mobile device support
│   │   │   └── mobile-support.nix
│   │   ├── 17-app-runtimes/                         # Non-native app runtimes
│   │   │   ├── appimage.nix
│   │   │   └── flatpak.nix
│   │   └── 18-ai-infra/                             # AI infrastructure (system-level)
│   │       └── ai-agent-stack.nix
│   │
│   ├── 20-services/                                 # ══ SYSTEM DAEMONS ══
│   │   ├── 21-networking/                           # Network services & DNS
│   │   │   ├── caddy.nix                            # Reverse proxy
│   │   │   ├── headscale.nix                        # VPN coordination
│   │   │   ├── tailscale.nix                        # VPN client
│   │   │   ├── avahi.nix                            # mDNS/DNS-SD
│   │   │   ├── adguard.nix                          # DNS filtering
│   │   │   └── ssh-agent.nix                        # SSH agent management
│   │   ├── 22-ai/                                   # AI services
│   │   │   ├── ai-services.nix                      # Ollama, LMStudio, etc.
│   │   │   ├── brain-service.nix                    # LlamaIndex knowledge base
│   │   │   ├── llm-agents.nix                       # numtide/llm-agents
│   │   │   ├── sillytavern.nix                      # SillyTavern frontend
│   │   │   ├── voice.nix                            # Voice services
│   │   │   └── wyoming.nix                          # Wyoming protocol
│   │   ├── 23-media/                                # Media management
│   │   │   ├── calibre-web.nix                      # eBook server
│   │   │   ├── deluge.nix                           # BitTorrent
│   │   │   ├── immich.nix                           # Photo management
│   │   │   ├── komga.nix                            # Comics/manga server
│   │   │   ├── media-stack.nix                      # *arr suite
│   │   │   └── transmission.nix                     # BitTorrent (alt)
│   │   ├── 24-communication/                        # Communication platforms
│   │   │   ├── matrix.nix                           # Matrix homeserver
│   │   │   ├── mautrix.nix                          # Matrix bridges
│   │   │   ├── karakeep.nix                         # Bookmarks
│   │   │   └── your-spotify.nix                     # Spotify analytics
│   │   ├── 25-data/                                 # Data storage & sync
│   │   │   ├── databases.nix                        # PostgreSQL, Redis
│   │   │   ├── nextcloud.nix                        # Cloud storage
│   │   │   ├── filebrowser.nix                      # Web file manager
│   │   │   ├── vaultwarden.nix                      # Password vault
│   │   │   ├── harmonia.nix                         # Nix binary cache
│   │   │   └── langfuse.nix                         # LLM analytics
│   │   ├── 26-monitoring/                           # Observability
│   │   │   ├── monitoring.nix                       # Prometheus + Grafana
│   │   │   ├── glances.nix                          # System dashboard
│   │   │   └── homepage-dashboard.nix               # Service portal
│   │   └── 27-automation/                           # Workflow & home automation
│   │       ├── home-assistant.nix                   # Home automation
│   │       ├── n8n.nix                              # Workflow engine
│   │       ├── searxng.nix                          # Meta search
│   │       └── pastebin.nix                         # Paste sharing
│   │
│   ├── 30-identity/                                 # ══ USERS & THEMING ══
│   │   ├── 31-users/                                # User definitions
│   │   │   ├── t0psh31f.nix
│   │   │   └── vps.nix
│   │   └── 32-themes/                               # Boot & display themes
│   │       ├── greeter.nix
│   │       ├── grub-lain.nix
│   │       ├── plymouth-hellonavi.nix
│   │       └── plymouth-matrix.nix
│   │
│   ├── 40-desktop/                                  # ══ GRAPHICAL ENVIRONMENT ══
│   │   ├── 41-hyprland/                             # Hyprland compositor (NixOS + HM)
│   │   │   ├── hyprland-system.nix                  # NixOS: programs.hyprland
│   │   │   ├── animations.nix                       # HM: animation config
│   │   │   ├── keybinds.nix                         # HM: key bindings
│   │   │   ├── monitors.nix                         # HM: monitor layout
│   │   │   ├── rules.nix                            # HM: window rules
│   │   │   ├── scripts.nix                          # HM: helper scripts
│   │   │   └── uwsm.nix                            # HM: session management
│   │   ├── 42-niri/                                 # Niri compositor (NixOS + HM)
│   │   │   ├── niri-system.nix                      # NixOS: programs.niri
│   │   │   ├── keybinds.nix
│   │   │   ├── outputs.nix
│   │   │   ├── settings.nix
│   │   │   └── uwsm.nix
│   │   ├── 43-noctalia/                             # Noctalia shell
│   │   │   ├── default.nix
│   │   │   ├── ipc.nix
│   │   │   └── mutable-includes.nix
│   │   ├── 44-de-frameworks/                        # Desktop environment integrations
│   │   │   ├── vicinae.nix                          # Vicinae DE framework
│   │   │   └── portals.nix                          # XDG desktop portals
│   │   ├── 45-file-managers/                        # GUI file managers
│   │   │   ├── dolphin.nix
│   │   │   ├── nemo.nix
│   │   │   └── file-managers-system.nix             # NixOS file manager support
│   │   ├── 46-terminal-emulators/                   # Terminal apps
│   │   │   ├── ghostty.nix
│   │   │   └── waveterm.nix
│   │   ├── 47-display/                              # Display & output management
│   │   │   └── shikane.nix                          # Automatic output profiles
│   │   └── 48-utilities/                            # Desktop utilities & accessories
│   │       ├── accessories.nix                      # Screenshot, clipboard, etc.
│   │       ├── udiskie.nix                          # USB auto-mount
│   │       └── social.nix                           # Social/messaging apps
│   │
│   ├── 50-cli-tui-programs/                                      # ══ TERMINAL ENVIRONMENT ══
│   │   ├── 51-shells/                               # Shell configs
│   │   │   ├── bash.nix
│   │   │   ├── zsh.nix
│   │   │   └── common.nix
│   │   ├── 52-editors/                              # Terminal editors
│   │   │   ├── helix.nix
│   │   │   └── fallbacks.nix
│   │   ├── 53-tools/                                # CLI utilities
│   │   │   ├── git.nix
│   │   │   ├── fzf.nix
│   │   │   ├── gpg.nix
│   │   │   ├── modern-utils.nix
│   │   │   ├── python.nix
│   │   │   ├── nix-tools.nix
│   │   │   └── system-utils.nix
│   │   ├── 54-multiplexers/                         # Terminal multiplexers
│   │   │   ├── zellij.nix
│   │   │   └── tmux.nix
│   │   ├── 55-prompt/                               # Shell prompt
│   │   │   └── starship.nix
│   │   ├── 56-file-managers/                        # TUI file managers
│   │   │   ├── yazi.nix
│   │   │   ├── superfile.nix
│   │   │   └── alternatives.nix
│   │   ├── 57-services/                             # User-level services
│   │   │   ├── podman.nix
│   │   │   ├── rclone.nix
│   │   │   └── local-ai.nix
│   │   ├── 58-theming/                              # Terminal theming
│   │   │   ├── matugen.nix
│   │   │   ├── themes.nix
│   │   │   └── vivid.nix
│   │   ├── 59-integrations/                         # Cross-tool integrations
│   │   │   ├── yazelix.nix
│   │   │   ├── yazelix-style.nix
│   │   │   └── keybindings.nix
│   │   ├── packages-dev.nix                         # Dev CLI package sets (← 13-packages/dev.nix)
│   │   └── 50-entry/                                # CLI entry points
│   │       ├── core.nix                             # Core HM config
│   │       └── cli-tui.nix                          # Headless-only entry point
│   │
│   ├── 60-gui-programs/                                      # ══ GRAPHICAL APPLICATIONS ══
│   │   ├── 61-browsers/                             # Web browsers
│   │   │   ├── brave.nix
│   │   │   └── librewolf.nix
│   │   ├── 62-media/                                # Media players & packages
│   │   │   ├── mpv.nix
│   │   │   ├── vlc.nix
│   │   │   ├── audio.nix
│   │   │   ├── spicetify.nix
│   │   │   └── packages-media.nix                   # Media package set (← 13-packages/media.nix)
│   │   ├── 63-documents/                            # Document viewers
│   │   │   └── zathura.nix
│   │   ├── 64-development/                          # Dev GUI tools
│   │   │   ├── vscode.nix
│   │   │   └── dev-tools.nix
│   │   ├── 65-gaming/                               # Gaming stack (unified multi-class)
│   │   │   ├── gaming.nix                           # ← gaming.nix (system: Steam/gamemode + HM: apps)
│   │   │   └── gaming-apps.nix                      # HM gaming apps
│   │   ├── 66-security/                             # Security tools & packages
│   │   │   ├── pentest-tools.nix
│   │   │   └── packages-pentest.nix                 # Pentest package set (← 13-packages/pentest.nix)
│   │   └── packages-desktop.nix                     # Desktop package set (← 13-packages/desktop.nix)
│   │
│   ├── 70-agents/                                   # ══ AI AUTOMATION ══
│   │   ├── 71-coding/                               # Coding assistants
│   │   │   ├── antigravity.nix
│   │   │   ├── claude-code.nix
│   │   │   ├── codex.nix
│   │   │   ├── gemini-cli.nix
│   │   │   └── opencode.nix
│   │   ├── 72-voice/                                # Voice & TTS
│   │   │   └── asr-tts/                             # agent-audio.nix, agent.py
│   │   ├── 73-tooling/                              # Agent infrastructure
│   │   │   ├── mcp.nix                              # Model Context Protocol
│   │   │   └── fabric-ai.nix                        # Fabric AI patterns
│   │   └── packages-ai.nix                          # AI package set (← 13-packages/ai.nix)
│   │
│   └── 90-profiles/                                 # ══ COMPOSITION LAYER ══
│       └── tags/
│           ├── workstation.nix                      # Full desktop + all services
│           ├── laptop.nix                           # Laptop-specific additions
│           ├── desktop.nix                          # Graphical environment
│           ├── server.nix                           # Headless server
│           ├── development.nix                      # Dev tools
│           ├── gaming.nix                           # Gaming features
│           ├── media.nix                            # Media services
│           ├── gpu-compute.nix                      # GPU workloads
│           └── ai.nix                               # AI services
│
├── modules/80-lib/                                  # ══ NIX LIBRARY ══
│   ├── 81-helpers/                                   # Custom Nix functions
│   │   ├── mkMachineFromTags.nix                    # Tag → profile resolver
│   │   └── mkDendriticModule.nix                    # Multi-class module wrapper
│   ├── 82-overlays/                                 # Custom nixpkgs overlays
│   ├── 83-packages/                                 # Custom package derivations
│   ├── 84-templates/                                # Disko/machine templates
│   ├── 85-tests/                                    # Nix evaluation tests
│   ├── 86-scripts/                                  # Helper shell scripts
│   └── 87-iso/                                      # ISO build configurations
```

> **Clan-core immovable paths:** `machines/`, `vars/`, `clan-services/`, `clan.nix`, `inventory.json`
> must remain at the flake root. Clan's auto-include system discovers machines by
> scanning `machines/<name>/` and vars via `vars/{per-machine,shared}/`. Moving these
> would break `clan machines list`, `clan vars`, and deployment commands.

### Unmapped Files
Any file under `flake-parts/` not explicitly listed in the migration maps below should be placed in the most semantically appropriate layer. When uncertain, create a comment in the file noting the placement decision and flag it for review.

---

## Complete File Migration Map

### 10-system/11-foundation/ ← `flake-parts/system/`

| Source | Target |
|--------|--------|
| `system/nix-settings.nix` | `11-foundation/nix-settings.nix` |
| `system/base.nix` | `11-foundation/base.nix` |
| `system/networking.nix` | `11-foundation/networking.nix` |
| `system/caches.nix` | `11-foundation/caches.nix` |
| `system/optimization.nix` | `11-foundation/optimization.nix` |
| `system/overlays.nix` | `11-foundation/overlays.nix` |
| `system/clan-lib.nix` | `11-foundation/clan-lib.nix` |
| `system/resource-limits.nix` | `11-foundation/resource-limits.nix` |
| `system/fonts.nix` | `11-foundation/fonts.nix` |

### 10-system/12-hardware/ ← `flake-parts/hardware/`

| Source | Target |
|--------|--------|
| `hardware/common.nix` | `12-hardware/common.nix` |
| `hardware/audio.nix` | `12-hardware/audio.nix` |
| `hardware/laptop.nix` | `12-hardware/laptop.nix` |
| `hardware/intel.nix` | `12-hardware/12.1-cpu/intel.nix` |
| `hardware/intel-7th-gen.nix` | `12-hardware/12.1-cpu/intel-7th-gen.nix` |
| `hardware/intel-12th-gen.nix` | `12-hardware/12.1-cpu/intel-12th-gen.nix` |
| `hardware/amd.nix` | `12-hardware/12.2-gpu/amd.nix` |
| `hardware/nvidia.nix` | `12-hardware/12.2-gpu/nvidia.nix` |
| `hardware/nvidia-hybrid.nix` | `12-hardware/12.2-gpu/nvidia-hybrid.nix` |
| `hardware/bluetooth.nix` | `12-hardware/12.3-peripherals/bluetooth.nix` |
| `hardware/touchpad.nix` | `12-hardware/12.3-peripherals/touchpad.nix` |
| `hardware/razer.nix` | `12-hardware/12.3-peripherals/razer.nix` |

### 10-system/13-packages/ ← `flake-parts/features/nixos/packages/`

| Source | Target |
|--------|--------|
| `packages/base.nix` | `13-packages/base.nix` |
| `packages/desktop.nix` | `13-packages/desktop.nix` |
| `packages/ai.nix` | `13-packages/ai.nix` |
| `packages/dev.nix` | `13-packages/dev.nix` |
| `packages/media.nix` | `13-packages/media.nix` |
| `packages/pentest.nix` | `13-packages/pentest.nix` |

### 10-system/ remaining ← `flake-parts/features/nixos/` + `system/`

| Source | Target |
|--------|--------|
| `features/nixos/virtualization.nix` | `10-system/14-virtualization/virtualization.nix` |
| `features/nixos/impermanence.nix` | `10-system/15-storage/impermanence.nix` |
| `features/nixos/mobile-support.nix` | `10-system/16-mobile/mobile-support.nix` |
| `features/nixos/appimage.nix` | `10-system/17-app-runtimes/appimage.nix` |
| `features/nixos/flatpak.nix` | `10-system/17-app-runtimes/flatpak.nix` |
| `system/nix-tools.nix` | `10-system/11-foundation/nix-tools.nix` |
| `system/ai-agent-stack.nix` | `10-system/18-ai-infra/ai-agent-stack.nix` |

### Package & gaming redistribution ← `flake-parts/features/nixos/packages/`

| Source | Target | Rationale |
|--------|--------|-----------|
| `packages/base.nix` | `10-system/13-packages/base.nix` | Foundational — stays in system |
| `packages/desktop.nix` | `60-gui-programs/packages-desktop.nix` | Desktop packages belong with GUI |
| `packages/dev.nix` | `50-cli-tui-programs/packages-dev.nix` | Dev tools are primarily CLI |
| `packages/media.nix` | `60-gui-programs/62-media/packages-media.nix` | Media packages with media apps |
| `packages/ai.nix` | `70-agents/packages-ai.nix` | AI packages with AI agents |
| `packages/pentest.nix` | `60-gui-programs/66-security/packages-pentest.nix` | Security packages with security tools |
| `features/nixos/gaming.nix` | `60-gui-programs/65-gaming/gaming.nix` | Gaming is primarily apps + multi-class handles system bits |

### 20-services/ ← `flake-parts/services/`

Split the old 18-file `infrastructure/` dump into focused sub-tiers:

| Source | Target |
|--------|--------|
| `services/infrastructure/{caddy,headscale,tailscale,avahi,adguard,ssh-agent}.nix` | `20-services/21-networking/` |
| `services/ai/` (6 files) | `20-services/22-ai/` |
| `services/media/` (6 files) | `20-services/23-media/` |
| `services/communication/` (4 files) | `20-services/24-communication/` |
| `services/infrastructure/{databases,nextcloud,filebrowser,vaultwarden,harmonia,langfuse}.nix` | `20-services/25-data/` |
| `services/infrastructure/{monitoring,glances,homepage-dashboard}.nix` | `20-services/26-monitoring/` |
| `services/infrastructure/{home-assistant,n8n,searxng,pastebin}.nix` | `20-services/27-automation/` |

### 30-identity/ ← `flake-parts/users/` + `flake-parts/themes/`

| Source | Target |
|--------|--------|
| `users/t0psh31f.nix` | `30-identity/31-users/t0psh31f.nix` |
| `users/vps.nix` | `30-identity/31-users/vps.nix` |
| `themes/greeter.nix` | `30-identity/32-themes/greeter.nix` |
| `themes/grub-lain.nix` | `30-identity/32-themes/grub-lain.nix` |
| `themes/plymouth-hellonavi.nix` | `30-identity/32-themes/plymouth-hellonavi.nix` |
| `themes/plymouth-matrix.nix` | `30-identity/32-themes/plymouth-matrix.nix` |

### 40-desktop/ ← NixOS desktop + HM desktop

Merges NixOS-level and HM-level desktop configs into unified modules:

| Source | Target |
|--------|--------|
| `features/nixos/desktop/hyprland-system.nix` | `40-desktop/41-hyprland/hyprland-system.nix` |
| `features/home/gui/desktop/hyprland/*.nix` (7) | `40-desktop/41-hyprland/` |
| `features/nixos/desktop/niri-system.nix` | `40-desktop/42-niri/niri-system.nix` |
| `features/home/gui/desktop/niri/*.nix` (5) | `40-desktop/42-niri/` |
| `features/home/gui/desktop/noctalia/*.nix` (3) | `40-desktop/43-noctalia/` |
| `features/nixos/desktop/portals.nix` | `40-desktop/44-de-frameworks/portals.nix` |
| `features/home/gui/desktop/vicinae.nix` | `40-desktop/44-de-frameworks/vicinae.nix` |
| `features/nixos/desktop/file-managers.nix` + `home/.../file-managers/` | `40-desktop/45-file-managers/` |
| `features/home/gui/desktop/terminal-emulators/` | `40-desktop/46-terminal-emulators/` |
| `features/home/gui/desktop/shikane.nix` | `40-desktop/47-display/shikane.nix` |
| `features/home/gui/desktop/accessories.nix` | `40-desktop/48-utilities/accessories.nix` |
| `features/home/gui/desktop/udiskie.nix` | `40-desktop/48-utilities/udiskie.nix` |
| `features/home/gui/desktop/social.nix` | `40-desktop/48-utilities/social.nix` |

### 50-cli-tui-programs/ ← `features/home/cli/`

| Source | Target |
|--------|--------|
| `features/home/cli/shells/` | `50-cli-tui-programs/51-shells/` |
| `features/home/cli/editors/` | `50-cli-tui-programs/52-editors/` |
| `features/home/cli/tools/` | `50-cli-tui-programs/53-tools/` |
| `features/home/cli/multiplexers/` | `50-cli-tui-programs/54-multiplexers/` |
| `features/home/cli/prompt/` | `50-cli-tui-programs/55-prompt/` |
| `features/home/cli/file-managers/` | `50-cli-tui-programs/56-file-managers/` |
| `features/home/cli/services/` | `50-cli-tui-programs/57-services/` |
| `features/home/cli/theming/` + `vivid.nix` | `50-cli-tui-programs/58-theming/` |
| `features/home/cli/integrations/` + `yazelix.nix` | `50-cli-tui-programs/59-integrations/` |
| `features/home/core.nix` + `cli-tui.nix` | `50-cli-tui-programs/50-entry/` |

### 60-gui-programs/ ← `features/home/gui/` (non-desktop)

| Source | Target |
|--------|--------|
| `features/home/gui/desktop/browsers/` | `60-gui-programs/61-browsers/` |
| `features/home/gui/desktop/media/` + `spicetify.nix` | `60-gui-programs/62-media/` |
| `features/home/gui/documents/` | `60-gui-programs/63-documents/` |
| `features/home/gui/vscode.nix` + `dev-tools.nix` | `60-gui-programs/64-development/` |
| `features/home/gui/gaming-apps.nix` + `nixos/gaming.nix` | `60-gui-programs/65-gaming/` |
| `features/home/gui/pentest-tools.nix` | `60-gui-programs/66-security/` |

### 70-agents/ ← `features/home/agent/`

| Source | Target |
|--------|--------|
| `features/home/agent/{antigravity,claude-code,codex,gemini-cli,opencode}.nix` | `70-agents/71-coding/` |
| `features/home/agent/asr-tts/` | `70-agents/72-voice/` |
| `features/home/agent/{mcp,fabric-ai}.nix` | `70-agents/73-tooling/` |

### 90-profiles/ — NEW

Created fresh. Tags compose modules from tiers 10–70.

### 00-cyberia/ — NEW (consolidating TLD clutter)

| Source | Target |
|--------|--------|
| `docs/` | `modules/00-cyberia/01-docs/` |
| `assets/` | `modules/00-cyberia/02-assets/` |
| `sops/` | `modules/00-cyberia/03-sops/` |
| `treasure/` | `modules/00-cyberia/04-treasure/` |
| `*.txt` scratch files | Delete or move to `00-cyberia/01-docs/` |

### 80-lib/ — NEW (Nix library & build infra)

| Source | Target |
|--------|--------|
| `lib/` (new helpers) | `modules/80-lib/81-helpers/` |
| `overlays/` | `modules/80-lib/82-overlays/` |
| `packages/` (custom derivations) | `modules/80-lib/83-packages/` |
| `templates/` | `modules/80-lib/84-templates/` |
| `tests/` + `test-*.nix` | `modules/80-lib/85-tests/` |
| `scripts/` | `modules/80-lib/86-scripts/` |
| `iso/` | `modules/80-lib/87-iso/` |

### Clan-required (stays at TLD)

| Path | Reason |
|------|--------|
| `machines/` | Clan auto-discovers `machines/<name>/` |
| `vars/` | Clan vars backend reads `vars/{per-machine,shared}/` |
| `clan-services/` | Clan service module discovery |
| `clan.nix` | Clan inventory configuration |
| `inventory.json` | Clan auto-managed |
| `flake.nix` / `flake.lock` | Nix requires these at root |

---

## Machines

> [!IMPORTANT]
> The tag assignments below are the **target state**. The current tags in `clan.nix`
> will be replaced during Phase 8 of this migration.

| Machine | Role | Current Status / Reality (`clan.nix`) | Target Tags |
|---------|------|---------------------------------------|-------------|
| **luffy** | GPU workstation | ⏸ Offline. Tags: `desktop`, `gaming`, `ai-heavy`, `nvidia` | `server`, `gpu-compute`, `ai` |
| **z0r0** | Primary workstation | ✅ Active. The convergent do-everything box. Tags: `desktop`, `laptop`, `ai-server`, `build-server`, `binary-cache`, `database`, `dev`, `media-server` | `workstation`, `desktop`, `development`, `gaming` |
| **nami** | Laptop | ✅ Active. Very minimal currently. Tags: `desktop` | `workstation`, `laptop`, `desktop`, `media` |

> [!WARNING]
> **Luffy has a minimal import footprint.**
> Luffy's `default.nix` does NOT import the full foundation/hardware/desktop stack.
> It cherry-picks specific service directories and uses a stub `options.system-config.impermanence.enable`.
> **DO NOT** expand its imports when creating the target profiles. It must remain minimal.

---

## Git Workflow

> [!IMPORTANT]
> **Safety First:** We must preserve the current working state before making any changes. If the refactor fails, we can simply delete the refactor branch and return to main.

### 1. Create a Safe Backup (Do this FIRST)
Create a timestamped backup branch of the current `main` state and leave it alone.
```bash
git branch backup-main-$(date +%Y%m%d-%H%M%S)
```

### 2. Start the Refactor
Create and switch to a brand new branch for the migration work.
```bash
git checkout -b refactor/dendritic-architecture
```

### 3. Commit After EVERY Phase
To ensure we can resume or rollback specific steps, you MUST commit after each phase completes successfully.
```bash
git add .
git commit -m "refactor: phase N — <description of phase work>"
```

### 4. Validation (Run before asking for approval)
```bash
nix flake check
nix build .#nixosConfigurations.z0r0.config.system.build.toplevel
nix build .#nixosConfigurations.nami.config.system.build.toplevel
```

### 5. Final Merge & Deploy (Phase 12)
Only after all phases are complete and explicit approval is given.
```bash
git checkout main
git merge --no-ff refactor/dendritic-architecture
nixos-rebuild dry-run --flake .#z0r0
nixos-rebuild switch --flake .#z0r0
```

---

## Execution Phases

Copy first → switch imports → delete old. Never broken paths.
**STOP after each phase** — report status, await permission.

**Multi-Session Note:** This refactor will likely span multiple conversations.
Each phase MUST end with a `git commit` on the refactor branch so a new session
can resume cleanly from that commit. Include the phase number in commit messages.

| Phase | Work | Validation |
|-------|------|-----------|
| **1** | Branch + create `/modules/` directory skeleton only | Visual check |
| **2** | `cp` (not `mv`) `10-system/` files to new locations | `git add . && nix flake check` |
| **3** | `cp` `20-services/` and `30-identity/` files | `git add . && nix flake check` |
| **4** | `cp` `40-desktop/`, `50-cli-tui-programs/`, `60-gui-programs/`, `70-agents/` | `git add . && nix flake check` |
| **5** | Create `90-profiles/`, `lib/mkMachineFromTags.nix`, `lib/mkDendriticModule.nix` | `git add . && nix flake check` |
| **6** | Wire new paths into machine configs, **remove old imports** | Build z0r0 + nami |
| **7** | Switch machine configs to use profiles instead of manual imports | Build z0r0 + nami |
| **8** | Delete old `flake-parts/` tree (except Home-Manager if any remains) | Build z0r0 + nami |
| **9** | Update clan inventory tags (`clan.nix`) | `nix flake check` |
| **10** | Code quality pass (formatting, comments, dedup) | Build z0r0 + nami |
| **11** | Option schema migration (`features.<tier>.<name>.enable`) | Build z0r0 + nami |
| **12** | Present summary → WAIT → merge + deploy | `dry-run` then `switch` |

---

## Code Quality Standards

Portfolio-quality. Every file intentional and professional.

- **No** comments restating code. **Yes** to non-obvious decisions & workarounds.
- One-line file purpose header on every module.
- `nixfmt` or `alejandra`, 2-space indent, grouped attribute sets.
- Repeated patterns → `lib/`, repeated imports → profiles.

---

## Remember

- **ZERO BEHAVIOR CHANGES** in structural phases
- **COPY FIRST, SWITCH, THEN DELETE**
- **CLAN-CORE IS SACRED** — do not bypass flake-parts or clan-core
- **LUFFY IS MINIMAL** — do not expand its imports
- **UNIFIED MODULES** — NixOS + HM in single files where sensible
- **PORTFOLIO QUALITY** — every file intentional
- **INTERACTIVE** — pause after each phase, await permission
- **COMMIT PER PHASE** — resumable checkpoints

You are not done until explicit approval is given.

🏴‍☠️
