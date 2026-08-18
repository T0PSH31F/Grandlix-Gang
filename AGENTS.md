# NFP — Agent Operating Instructions

> This file is automatically read by OpenCode and any AI agent working in this repository.
> It defines the rules, conventions, and critical knowledge for working with the NFP flake.

---

## 1. Documentation — Read, Refer, Update

The `layers/00-cyberia/01-docs/` directory is the **canonical knowledge base** for this repository.

### Rules
- **READ** the relevant docs before making changes to any system component
- **REFER** to docs when uncertain about architecture, service ports, or deployment methods
- **UPDATE** docs when you add, remove, or significantly modify features, services, or architecture
- **ORGANIZE** docs logically — if a new subsystem is added, create or update the appropriate doc file

### Key Documents

| Document | Purpose |
|----------|---------|
| `AGENT_ONBOARDING.md` | System overview, boot flow, impermanence, recovery, known issues — **read first** |
| `services.md` | All service ports, URLs, and logins across the fleet |
| `ports.md` | Port allocation registry — check before adding new services |
| `features.md` | High-level feature overview (desktop, editor, CLI, AI stack) |
| `hermes-agent.md` | Hermes AI agent architecture and configuration |
| `deployment.md` | Deployment methods and commands |
| `deploy-from-live.md` | Recovery deployment from live USB |
| `yazelix_guide.md` | NixVim/editor configuration guide |
| `progress.md` | Session progress log — update after significant work sessions |
| `RECOVERY_NOTE.md` | Recovery history and notes |

### Agent Rules (`.agents/rules/`)

| Rule File | Trigger |
|-----------|---------|
| `clan-architecture.md` | When managing secrets, passwords, tokens, or creating new services |
| `organization.md` | When performing structural refactors of the repository |
| `recovery.md` | When performing system recovery |

---

## 2. Build & Deploy Commands

### ALWAYS use Clan machine updates — never raw nixos-rebuild

```bash
# Update all machines in the fleet
clan machines update

# Update a specific machine
clan machines update z0r0
clan machines update luffy

# Update multiple specific machines
clan machines update z0r0 luffy
```

**NEVER** use `nixos-rebuild switch/boot` directly unless:
- `clan machines update` is unavailable or broken
- You are in a recovery chroot from a live USB
- You are debugging a build failure and need `--dry-run` or `--check`

### Why Clan over nixos-rebuild
- Clan handles remote deployment, secret distribution, and machine inventory
- `clan machines update` wraps nixos-rebuild with proper flake targeting
- It ensures secrets (SOPS) are deployed correctly before activation

---

## 3. Determinism — All Config Through the Flake

### The Golden Rule
**Every configuration change must be made through the NFP flake.** Never edit generated files directly.

### Home-Manager Managed Files
Files like `opencode.json`, `tui.json`, `himalaya config.toml`, and other dotfiles are **symlinks to the Nix store** managed by home-manager. Direct edits are:
1. Lost on every rebuild
2. Not reproducible
3. A source of silent configuration drift

### How to make changes
- Edit the corresponding Nix module in `layers/` (e.g., `layers/70-agents/71-coding/opencode.nix`)
- For new MCP servers, add them to `layers/70-agents/71-coding/opencode/server-catalog.nix` or the `settings` block
- For new packages, add them to the appropriate layer module (e.g., `layers/50-cli-tui-programs/`)
- For new services, add them to `layers/20-services/` with proper clan vars for secrets
- For new overlays, add them to `layers/80-lib/82-overlays/custom-packages.nix`

### Secrets
- **NEVER** hardcode secrets in Nix files
- **ALWAYS** use `clan.core.vars` with the sops backend
- See `.agents/rules/clan-architecture.md` for the implementation pattern

---

## 4. System Architecture

### Machines

| Machine | Role | Hardware | Deploy Target |
|---------|------|----------|---------------|
| **z0r0** | Laptop workstation, AI server, dev | LG 17Z90Q, i7-1260P, 16GB RAM | `root@127.0.0.1` (local) |
| **luffy** | Server, homelab, cache, AI, agent control plane | Intel 9th gen, remote | `root@100.80.146.120` (Tailscale) |

### Flake Structure (Dendritic Layers)

```
NFP/
├── flake.nix              # flake-parts + clan-core
├── clan.nix               # machine inventory, clan services
├── machines/              # per-machine config (z0r0, luffy)
├── layers/                 # dendritic layered modules
│   ├── 00-cyberia/        # templates, tests, docs, devshells
│   ├── 10-system/         # foundation, processor, users, filesystem
│   ├── 20-services/       # networking, AI, media, communication
│   ├── 30-theming/        # themes (Noctalia)
│   ├── 40-desktop/        # desktop environments (Hyprland)
│   ├── 50-cli-tui-programs/ # CLI/TUI tools (himalaya, git, etc.)
│   ├── 60-gui-programs/   # GUI apps (gaming, browsers, documents)
│   ├── 70-agents/         # AI agents (opencode, hermes)
│   ├── 80-lib/            # overlays, custom packages
│   └── 90-profiles/tags/  # tag-based profiles
├── .agents/rules/          # agent rule files
└── layers/00-cyberia/01-docs/  # canonical documentation
```

### Shared vs Machine-Specific
- **Shared** (affects BOTH machines): everything in `layers/`
- **z0r0-only**: `machines/z0r0/default.nix`, `machines/z0r0/hardware.nix`
- **luffy-only**: `machines/luffy/default.nix`

---

## 5. Known Issues

| Issue | Status | Workaround |
|-------|--------|------------|
| `util-linux-2.42` broken symlink references | Active | GC roots added at boot; use `nix-safe-gc` only |
| UniPet source hash + npm deps hash (`sha256` stale) | **Fixed** (2026-07-25) | Source tarball hash and npm deps hash both updated in `layers/80-lib/82-overlays/custom-packages.nix`. The `npmDepsHash` was previously set to `lib.fakeHash` (placeholder); replaced with real hash `sha256-jDqXZMd+3jVInzWb3R1mxwTqhTSOFtUrbfMkAyJt7EI=`. Source hash updated to `sha256-+bP60vOnCsmEknSSYZ5kxY0xfXEUHZY9dKtVWBofo5A=`. |
| Camoufox v135 `libgkcodecs.so` SIGSEGV on glibc ≥ 2.42 | **Resolved** (2026-07-03) | Bumped prebuilt to v150.0.2-beta.25 in `layers/80-lib/82-overlays/custom-packages.nix`; also patches the missing-`await` and `isMobile` CDP bugs in the bundled camofox-browser 1.11.2 / playwright-core 1.61.1 |
| Steam/lutris/steam-run fhsenv-rootfs build failure (`libmount.so.1`) | **Fixed** (2026-07-25) | Root cause: `glib` 2.88.1 links `glib-compile-schemas` against `libmount.so.1` from `util-linuxMinimal` but won't propagate it (`buildInputs` only, not `propagatedBuildInputs`). fhsenv rootfs builders run `glib-compile-schemas` in a sandbox without `libmount.so.1` available. Fix: patched `buildFHSEnvBubblewrap` via overlay in `layers/80-lib/82-overlays/custom-packages.nix` to inject a glib build that propagates `util-linuxMinimal` — but ONLY for fhsenv rootfs derivations (no global glib rebuild). The earlier `extraPackages` fix (2026-07-24) was ineffective. |
| `cache.numtide.com` binary cache timeout | Active (mitigated) | Cache server unreachable from this network. Moved to end of substituter lists in `flake.nix` and `caches.nix` so timeouts don't delay more reliable caches |
| openrazer incompatible with linux 7.0.10 | Active | Disabled: `peripherals.razer.enable = lib.mkForce false` |
| LM Studio packaging error in unstable | Active | Disabled: `ai-services.lmstudio.enable = lib.mkForce false` |

### Critical: Never run `nix-store --gc`
The util-linux broken-reference bug will delete boot-critical paths. Use `nix-safe-gc` or `nix-collect-garbage --delete-older-than 14d` instead.

---

## 6. AI Agent Infrastructure

### OpenCode (Orchestrator)
- Config: `layers/70-agents/71-coding/opencode.nix`
- MCP servers: `layers/70-agents/71-coding/opencode/server-catalog.nix`
- Plugin: `oh-my-opencode-slim` (presets, companion app, skills)
- Preset config: `~/.config/opencode/oh-my-opencode-slim.json` (managed by installer — needs flake integration)

### Hermes-Agent (Autonomous Worker)
- Config: `layers/70-agents/76-hermes-agent/hermes.nix`
- Runtime config: `~/.hermes/config.yaml`
- Gateway: `127.0.0.1:8085` (MCP protocol)
- Dashboard: `127.0.0.1:9119` (REST API, no auth)
- Browser: `127.0.0.1:9377` (jo-camofox-browser — jo-inc fork with VNC at `:6080`, per-userId session isolation, persistence plugin). Overlay: `camoufox-nix`. Service: `layers/20-services/24-communication/camofox-browser.nix`. Prebuilt camoufox v150 in `layers/80-lib/82-overlays/custom-packages.nix`.
- Signal: `127.0.0.1:8080`
- Personalities: 20 available, GLaDOS is default
- Voice: STT (Whisper local) + TTS (8 providers including GLaDOS local)

### Email Pipeline (Shared)
- himalaya CLI: `layers/50-cli-tui-programs/53-tools/himalaya.nix`
- himalaya-mcp: `~/Projects/himalaya-mcp/dist/index.js` (built from source)
- himalaya config: `~/.config/himalaya/config.toml` (needs flake integration)
- Accounts: `wrighterik77@gmail.com`, `lovelainautomations@gmail.com`
- Telegram bot: `~/.local/bin/telegram-notify.sh` (SOPS token `tg_botfather_http`)
- GLaDOS voice alerts: `~/.local/bin/glados-alert.sh`

### GLaDOS Voice Project
- Location: `~/Projects/GlaDos/GLaDOS/`
- TTS: Piper ONNX (`glados.onnx` model)
- ASR: Parakeet TDT (0.6B model)
- MCP servers: slow_clap, system_info, memory, time, disk, network, process, power
- Constitution: behavioral bounds with adjustable snark_level (0.3–1.0)

---

## 7. Conventions

### File Organization
- New packages go in the appropriate layer (50 for CLI, 60 for GUI)
- New services go in `layers/20-services/` with a subdirectory
- New agents go in `layers/70-agents/` with a subdirectory
- New overlays go in `layers/80-lib/82-overlays/custom-packages.nix`

### Naming
- Layer directories: `XX-category/YY-subcategory/module.nix`
- Machine configs: `machines/<hostname>/default.nix`
- Tag profiles: `layers/90-profiles/tags/<tag-name>.nix`

### Commit Style
- Follow existing repo style
- Reference the layer/module affected in commit messages
- Note any cross-machine impact (shared layers affect both z0r0 and luffy)
- **Atomic Commits & Pushes**: All code changes, refactors, and system updates MUST be committed and pushed atomically (complete self-contained commits and pushes without leaving transient half-applied changes).

---

## 8. Recovery

For boot failures, recovery from live USB, and diagnosis:
1. Read `layers/00-cyberia/01-docs/AGENT_ONBOARDING.md` sections 7-8
2. Read `layers/00-cyberia/01-docs/RECOVERY_NOTE.md`
3. Read `.agents/rules/recovery.md`

### Quick Recovery Commands
```bash
# Mount system from live USB
cd ~/Clan/NFP && ./tools/mount-nfp.sh z0r0

# Chroot and rebuild
sudo nixos-enter --root /mnt
cd /persist/home/t0psh31f/Clan/NFP
nixos-rebuild boot --flake .#z0r0
```