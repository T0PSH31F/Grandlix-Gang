# NFP Layered Architecture Migration

> **Scope:** Structural refactor of the NFP NixOS configuration from a flat
> feature-based layout to a numbered-layer architecture with tag-based
> profile composition — while preserving clan-core and flake-parts integration.

---

## Success Criteria

| # | Requirement |
|---|-------------|
| 1 | All existing functionality preserved — zero behavior changes |
| 2 | `nix flake check` passes cleanly |
| 3 | `z0r0` and `nami` build successfully (luffy preserved but not deployed) |
| 4 | Clean, professional, portfolio-ready code quality |
| 5 | Git workflow followed exactly as specified |
| 6 | Explicit approval obtained before merging to main |

---

## Git Workflow

### Step 1 — Branch Setup

```bash
git branch backup-main-$(date +%Y%m%d-%H%M%S)
git checkout -b refactor/layered-architecture
```

### Step 2 — Development Rules

- All work happens on `refactor/layered-architecture`
- Commit after every phase with the phase number: `git commit -m "refactor: phase N — description"`
- Each commit is a resumable checkpoint for multi-session work
- DO NOT push to main until explicitly approved

### Step 3 — Validation (before requesting approval)

```bash
git add .
nix flake check
nix build .#nixosConfigurations.z0r0.config.system.build.toplevel
nix build .#nixosConfigurations.nami.config.system.build.toplevel
# luffy: verify evaluation only — not currently deployed
nix eval .#nixosConfigurations.luffy.config.system.build.toplevel --raw 2>&1 | head -1
```

### Step 4 — Approval Gate

Present: summary of changes → validation results → directory tree → git status.
Then ask: *"Ready to merge to main?"* — STOP and WAIT.

### Step 5 — Merge & Deploy (only after approval)

```bash
git checkout main
git merge --no-ff refactor/layered-architecture -m "refactor: migrate to layered architecture with tag-based profiles"
nixos-rebuild dry-run --flake .#z0r0   # safety check
nixos-rebuild switch --flake .#z0r0    # deploy
```

---

## Repository Context

**Repo:** `github:T0PSH31F/NFP` — Public portfolio project, code quality matters.
**Primary user:** `t0psh31f`

### Machines

| Machine | Role | Status | Notes |
|---------|------|--------|-------|
| **z0r0** | Primary workstation | ✅ Active | Full desktop, AI services, development, all services |
| **nami** | Laptop | ✅ Active | Desktop, media services, lighter workload |
| **luffy** | GPU workstation | ⏸ Offline | Config preserved but not currently deployed. Will return in the future. |

---

## Flake Architecture Preservation

> [!CAUTION]
> The flake uses **flake-parts + clan-core** — NOT raw `lib.nixosSystem`.
> Machines are defined in `clan.nix` → `machines.*` blocks.
> Do NOT replace this architecture with raw nixosSystem calls.

### Must Preserve

| Component | Location | Purpose |
|-----------|----------|---------|
| `flake-parts.lib.mkFlake` | `flake.nix` | Flake scaffold |
| `clan-core.flakeModules.default` | `flake.nix` imports | Clan machine management |
| `clan.pkgsForSystem` | `flake.nix` | Nixpkgs instantiation with overlays |
| `clan.machines.*` | `clan.nix` | Machine module definitions |
| `clan.inventory` | `flake-parts/clan-inventory.nix` | Tag-based service deployment |
| `flake.clan.modules` | `flake.nix` | Custom clan service registration |
| `flake.homeConfigurations` | `flake.nix` | Standalone `root@vps` home config |
| `perSystem` | `flake.nix` | Dev shells, checks, ISO builds |
| `clan-services/` | Root | Custom clan service definitions |

### Integration Strategy for `mkMachineFromTags`

The `mkMachineFromTags` helper generates an import list from tags. It is used
**inside** each `clan.machines.${name}` block as an additional import — it does
NOT replace the clan-core machine definition pattern.

```nix
# clan.nix — target pattern
machines.z0r0 = {
  imports = [
    (import ./lib/mkMachineFromTags.nix {
      inherit lib;
      tags = [ "workstation" "desktop" "development" "gaming" ];
    })
    ./machines/z0r0
  ];
  # Machine-specific overrides here
};
```

---

## Current Structure (Actual State)

```
NFP/
├── flake.nix                              # flake-parts + clan-core scaffold
├── clan.nix                               # Machine definitions + clan inventory instances
├── flake-parts/
│   ├── clan-inventory.nix                 # Tag-based service deployment (importer, sshd, users)
│   ├── system/                            # Foundation: base, nix-settings, networking, etc. (12 files)
│   ├── hardware/                          # Hardware profiles: amd, nvidia, intel, etc. (13 files)
│   ├── themes/                            # Boot themes: grub, plymouth, greeter (5 files)
│   ├── features/
│   │   ├── nixos/                         # System features: gaming, flatpak, desktop, etc. (15 files)
│   │   └── home/                          # Home-manager features: CLI, GUI, agents (80+ files)
│   ├── services/
│   │   ├── ai/                            # AI services (7 files)
│   │   ├── infrastructure/                # Infra services (18 files)
│   │   ├── media/                         # Media services (7 files)
│   │   └── communication/                 # Comms services (5 files)
│   └── users/                             # User definitions (2 files)
├── machines/{z0r0,nami,luffy}/            # Machine-specific configs + hardware
├── clan-services/                         # Custom clan service modules
└── overlays/                              # Custom package overlays
```

---

## Target Structure

```
NFP/
├── flake.nix                              # PRESERVED — flake-parts + clan-core
├── clan.nix                               # UPDATED — uses mkMachineFromTags
├── lib/
│   └── mkMachineFromTags.nix              # NEW — tag → profile resolver
├── modules/
│   ├── 00-foundation/                     # Nix, boot, locale, networking, caches, overlays
│   ├── 10-hardware/                       # Hardware profiles (GPU, audio, bluetooth, etc.)
│   ├── 20-system/                         # Virtualization, impermanence, packages, appimage, flatpak
│   ├── 30-services/                       # AI, infrastructure, media, communication
│   ├── 40-desktop/                        # Wayland compositors, themes, portals, file managers
│   └── 50-development/                    # Dev tools, nix-tools, AI agent stack
├── profiles/
│   └── tags/                              # workstation.nix, laptop.nix, server.nix, etc.
├── home/                                  # Home-manager features (PRESERVED from flake-parts/features/home/)
├── users/                                 # User definitions (PRESERVED from flake-parts/users/)
├── machines/                              # Minimal host-specific overrides
├── clan-services/                         # PRESERVED — custom clan services
├── overlays/                              # PRESERVED — custom overlays
└── docs/                                  # Documentation
```

---

## Complete Migration Mappings

### Critical Rule: Option Preservation in Phases 1–8

During the structural move (Phases 1–8), **ONLY** move files to new locations
and update `imports = []` paths. Keep all Nix options (like `gaming.enable`,
`services.caddy-server.enable`, etc.) exactly as they currently are. Do NOT
rename option namespaces yet. Phase 9 handles the schema migration.

### Layer 00 — Foundation

| Source | Target |
|--------|--------|
| `flake-parts/system/base.nix` | `modules/00-foundation/base.nix` |
| `flake-parts/system/nix-settings.nix` | `modules/00-foundation/nix-settings.nix` |
| `flake-parts/system/networking.nix` | `modules/00-foundation/networking.nix` |
| `flake-parts/system/caches.nix` | `modules/00-foundation/caches.nix` |
| `flake-parts/system/optimization.nix` | `modules/00-foundation/optimization.nix` |
| `flake-parts/system/overlays.nix` | `modules/00-foundation/overlays.nix` |
| `flake-parts/system/clan-lib.nix` | `modules/00-foundation/clan-lib.nix` |
| `flake-parts/system/resource-limits.nix` | `modules/00-foundation/resource-limits.nix` |
| `flake-parts/system/fonts.nix` | `modules/00-foundation/fonts.nix` |

Create `modules/00-foundation/default.nix` that imports all of the above.

### Layer 10 — Hardware

| Source | Target |
|--------|--------|
| `flake-parts/hardware/*.nix` (all 13 files) | `modules/10-hardware/*.nix` |

Preserve the existing `default.nix` aggregator. This is a direct directory move.

### Layer 20 — System

| Source | Target |
|--------|--------|
| `flake-parts/features/nixos/virtualization.nix` | `modules/20-system/virtualization.nix` |
| `flake-parts/features/nixos/impermanence.nix` | `modules/20-system/impermanence.nix` |
| `flake-parts/features/nixos/appimage.nix` | `modules/20-system/appimage.nix` |
| `flake-parts/features/nixos/flatpak.nix` | `modules/20-system/flatpak.nix` |
| `flake-parts/features/nixos/mobile-support.nix` | `modules/20-system/mobile-support.nix` |
| `flake-parts/features/nixos/gaming.nix` | `modules/20-system/gaming.nix` |
| `flake-parts/features/nixos/packages/` (all 7 files) | `modules/20-system/packages/` |
| `flake-parts/system/ai-agent-stack.nix` | `modules/20-system/ai-agent-stack.nix` |
| `flake-parts/system/nix-tools.nix` | `modules/20-system/nix-tools.nix` |

Create `modules/20-system/default.nix` that imports all of the above.

### Layer 30 — Services

| Source | Target |
|--------|--------|
| `flake-parts/services/ai/*.nix` (7 files) | `modules/30-services/ai/` |
| `flake-parts/services/infrastructure/*.nix` (18 files) | `modules/30-services/infrastructure/` |
| `flake-parts/services/media/*.nix` (7 files) | `modules/30-services/media/` |
| `flake-parts/services/communication/*.nix` (5 files) | `modules/30-services/communication/` |

Preserve the existing `default.nix` aggregators within each subdirectory.
Create a top-level `modules/30-services/default.nix` that imports all four subdirectories.

### Layer 40 — Desktop

| Source | Target |
|--------|--------|
| `flake-parts/features/nixos/desktop/*.nix` (5 files) | `modules/40-desktop/` |
| `flake-parts/themes/*.nix` (5 files) | `modules/40-desktop/themes/` |

Create `modules/40-desktop/default.nix` that imports the desktop modules and themes.

### Unchanged Directories (preserve at new top-level paths)

| Source | Target | Notes |
|--------|--------|-------|
| `flake-parts/features/home/` | `home/` | Move to top-level; 80+ files, preserve internal structure |
| `flake-parts/users/` | `users/` | Move to top-level |
| `flake-parts/clan-inventory.nix` | `clan/inventory.nix` | Move into clan/ directory |
| `clan-services/` | `clan-services/` | No change |
| `overlays/` | `overlays/` | No change |
| `machines/` | `machines/` | No change to directory; update imports inside files |

---

## Profile Implementations

### Design Principle: Tag-Agnostic Layers

Layer modules are **tag-agnostic** — they expose `enable` toggles but never
inspect machine tags. Profile files (`profiles/tags/*.nix`) are the **only**
place where tags map to enable toggles. This keeps layers reusable and testable.

### Workstation Profile

```nix
# profiles/tags/workstation.nix
# Composition profile for desktop workstations (z0r0, nami)
{ ... }: {
  imports = [
    ../modules/00-foundation
    ../modules/10-hardware
    ../modules/20-system
    ../modules/30-services
    ../modules/40-desktop
  ];
}
```

### Laptop Profile

```nix
# profiles/tags/laptop.nix
# Additional configuration for laptop hardware
{ ... }: {
  imports = [
    # Laptop-specific hardware (touchpad, power management)
  ];
}
```

### Server Profile

```nix
# profiles/tags/server.nix
# Composition profile for headless servers
{ ... }: {
  imports = [
    ../modules/00-foundation
    ../modules/10-hardware
    ../modules/20-system
    ../modules/30-services
  ];
  # No desktop layer — headless
}
```

> [!IMPORTANT]
> Profiles must NOT add new services or features that weren't already enabled
> on that machine. They only compose layers. Machine-specific enable toggles
> remain in `machines/*/default.nix`.

---

## `lib/mkMachineFromTags.nix`

```nix
# lib/mkMachineFromTags.nix
# Resolves machine tags to profile imports.
# Used inside clan.machines.* blocks — does NOT replace clan-core.
{ lib, tags }:
let
  tagToProfile = tag:
    let path = ../profiles/tags/${tag}.nix;
    in if builtins.pathExists path
       then [ path ]
       else builtins.trace "WARN: No profile for tag '${tag}'" [];

  profileImports = lib.flatten (map tagToProfile tags);
in {
  imports = profileImports;
  _module.args.machineTags = tags;
}
```

---

## Machine Tag Assignments (Target State)

> These are the **target** tags for the refactored architecture. They replace
> the current tags in `clan.nix`.

| Machine | Tags | Notes |
|---------|------|-------|
| **z0r0** | `workstation`, `desktop`, `development`, `gaming` | Primary workstation — all layers |
| **nami** | `workstation`, `laptop`, `desktop`, `media` | Laptop — lighter workload |
| **luffy** | `server`, `gpu-compute`, `ai` | Offline — preserve config, skip build validation |

---

## Updated `clan.nix` (Target)

```nix
# clan.nix — Clan machine definitions with tag-based profile composition
{
  lib,
  ...
}: {
  meta.name = "NFP";

  inventory = {
    machines = {
      z0r0 = {
        tags = [ "workstation" "desktop" "development" "gaming" ];
        deploy.targetHost = "root@z0r0.local";
      };
      nami = {
        tags = [ "workstation" "laptop" "desktop" "media" ];
        deploy.targetHost = "root@nami.local";
      };
      luffy = {
        tags = [ "server" "gpu-compute" "ai" ];
        # deploy.targetHost not set — machine offline
      };
    };

    # Service instances remain unchanged — preserve existing clan-inventory.nix content
    instances = { /* ... preserved from clan/inventory.nix ... */ };
  };

  machines = {
    z0r0 = {
      imports = [
        (import ./lib/mkMachineFromTags.nix {
          inherit lib;
          tags = [ "workstation" "desktop" "development" "gaming" ];
        })
        ./machines/z0r0
      ];
    };
    nami = {
      imports = [
        (import ./lib/mkMachineFromTags.nix {
          inherit lib;
          tags = [ "workstation" "laptop" "desktop" "media" ];
        })
        ./machines/nami
      ];
    };
    luffy = {
      imports = [
        (import ./lib/mkMachineFromTags.nix {
          inherit lib;
          tags = [ "server" "gpu-compute" "ai" ];
        })
        ./machines/luffy
      ];
    };
  };
}
```

---

## Code Quality Standards

This is a **public portfolio repo**. Every file should look intentional.

### Comments

- ❌ No comments that restate code (`# Enable docker` above `enable = true`)
- ✅ Comments for non-obvious decisions, workarounds, or security rationale
- ✅ File-level header comments: one-line purpose statement

### Formatting

- Use `nixfmt` or `alejandra` — consistent 2-space indentation
- Group related options with attribute sets, not repeated prefixes
- Alphabetize imports where logical
- Use `mkDefault`, `mkForce`, `mkIf` appropriately

### Deduplication

- Repeated patterns → shared functions in `lib/`
- Repeated imports → profile composition
- Repeated service configs → extract to layers

### Module Structure (Phase 9 Target)

```nix
# modules/<NN>-<layer>/<module>.nix
# Brief purpose statement
{ config, lib, ... }: {
  options.<namespace>.<module> = {
    enable = lib.mkEnableOption "<description>";
  };

  config = lib.mkIf config.<namespace>.<module>.enable {
    # Configuration
  };
}
```

---

## Execution Phases

### Multi-Session Resilience

This refactor will likely span multiple conversations. Each phase ends with a
`git commit` on the refactor branch. A new session resumes from the latest
commit. Include the phase number in commit messages.

### Phase 1 — Setup (5 min)

1. Create backup branch + refactor branch
2. Create directory skeleton (`modules/`, `profiles/`, `lib/`, `clan/`, `home/`, `users/`)
3. `git commit -m "refactor: phase 1 — directory skeleton"`
4. **STOP** — report status, await permission

### Phase 2 — Foundation & Hardware (20 min)

1. **Copy** (not move) files to `modules/00-foundation/` and `modules/10-hardware/`
2. Write `default.nix` aggregators in each new directory
3. Verify old imports still work: `git add . && nix flake check`
4. `git commit -m "refactor: phase 2 — foundation and hardware layers"`
5. **STOP** — report status, await permission

### Phase 3 — System & Services (30 min)

1. **Copy** files to `modules/20-system/` and `modules/30-services/`
2. Write `default.nix` aggregators
3. Verify: `git add . && nix flake check`
4. `git commit -m "refactor: phase 3 — system and services layers"`
5. **STOP** — report status, await permission

### Phase 4 — Desktop & Home (20 min)

1. **Copy** files to `modules/40-desktop/`
2. **Move** `flake-parts/features/home/` → `home/`
3. **Move** `flake-parts/users/` → `users/`
4. **Move** `flake-parts/clan-inventory.nix` → `clan/inventory.nix`
5. Update all import paths that reference the moved home/users/inventory files
6. Verify: `git add . && nix flake check`
7. `git commit -m "refactor: phase 4 — desktop layer, home and users relocated"`
8. **STOP** — report status, await permission

### Phase 5 — Profiles & Tags (30 min)

1. Create `lib/mkMachineFromTags.nix`
2. Create profile files in `profiles/tags/`
3. Verify profiles resolve correctly: `git add . && nix flake check`
4. `git commit -m "refactor: phase 5 — profiles and mkMachineFromTags"`
5. **STOP** — report status, await permission

### Phase 6 — Switch Machine Imports (30 min)

1. Update `clan.nix` to use `mkMachineFromTags` pattern
2. Update `machines/z0r0/default.nix` — replace old `../../flake-parts/...` imports with profile-based composition
3. Update `machines/nami/default.nix` — same
4. Update `machines/luffy/default.nix` — same (preserve its selective import pattern)
5. Update `flake.nix` — point to `clan/inventory.nix` instead of old path
6. Build validation:
   ```bash
   git add .
   nix flake check
   nix build .#nixosConfigurations.z0r0.config.system.build.toplevel
   nix build .#nixosConfigurations.nami.config.system.build.toplevel
   ```
7. `git commit -m "refactor: phase 6 — machines switched to layered imports"`
8. **STOP** — report status, await permission

### Phase 7 — Cleanup (20 min)

1. **Delete** old `flake-parts/` directory entirely (everything has been copied/moved out)
2. Remove any orphaned imports or dead code
3. Build validation — all three checks from Phase 6
4. `git commit -m "refactor: phase 7 — old structure removed"`
5. **STOP** — report status, await permission

### Phase 8 — Code Quality Pass (30 min)

1. Remove redundant comments across all files
2. Apply consistent formatting
3. Add clean file-level header comments
4. Deduplicate any repeated patterns
5. Verify: `git add . && nix flake check` + build z0r0 and nami
6. `git commit -m "refactor: phase 8 — code quality polish"`
7. **STOP** — report status, await permission

### Phase 9 — Option Schema Migration (60 min)

1. Rename option namespaces to match new layer structure where beneficial
2. Update all references in machine configs and profiles
3. Full build validation of z0r0 and nami
4. `git commit -m "refactor: phase 9 — option schema migration"`
5. **STOP** — report status, await permission

### Phase 10 — Approval & Deploy

1. Present: summary → validation results → `tree` output → git log
2. **WAIT** for explicit approval
3. Merge + dry-run + deploy

---

## Error Handling

**If `nix flake check` fails:**
1. Read the error carefully
2. Fix the issue — do NOT proceed to the next phase
3. Re-validate before continuing

**If a machine build fails:**
1. Check import paths and option references
2. Verify hardware.nix is correctly referenced
3. For luffy: if it fails due to missing inputs or stubs, add minimal stubs and document them

**If uncertain about placement:**
1. Place the file in the most semantically appropriate layer
2. Add a `# TODO: Verify placement` comment
3. Flag for review at the end of the phase

---

## Luffy-Specific Handling

Luffy is **offline** and has a deliberately **minimal import footprint** — it
does NOT import `flake-parts/system`, `flake-parts/features/nixos`,
`flake-parts/hardware`, or `flake-parts/themes`. It only imports:

- `./hardware.nix`, `./containers.nix`
- `flake-parts/services/ai/ai-services.nix` (single file, not the dir)
- `flake-parts/services/infrastructure`
- `flake-parts/services/media`
- `flake-parts/users/t0psh31f.nix`
- `inputs.impermanence.nixosModules.impermanence`
- `inputs.home-manager.nixosModules.home-manager`

It also defines a **stub option** (`options.system-config.impermanence.enable`)
to satisfy references from imported modules.

When migrating luffy:
- Use a **minimal server profile** that only imports the layers luffy actually needs
- Preserve the stub option until the full option schema migration
- Do NOT accidentally expand its imports by giving it a profile that pulls in desktop/foundation layers it never used

---

## Validation Checklist

### Builds

- [ ] `nix flake check` passes
- [ ] z0r0 builds successfully
- [ ] nami builds successfully
- [ ] luffy evaluates without error (build not required)

### Structure

- [ ] All `modules/` directories created with `default.nix` aggregators
- [ ] All `profiles/tags/` created
- [ ] `lib/mkMachineFromTags.nix` implemented
- [ ] `clan/inventory.nix` in place
- [ ] `home/` and `users/` at top level
- [ ] Old `flake-parts/` fully removed
- [ ] `machines/` reduced to host-specific overrides only

### Preservation

- [ ] `flake.nix` still uses flake-parts + clan-core
- [ ] `clan.nix` still defines machines via `clan.machines.*`
- [ ] `flake.homeConfigurations.root@vps` preserved
- [ ] `perSystem` (devShells, checks, ISO) preserved
- [ ] `flake.clan.modules` preserved
- [ ] `clan-services/` preserved
- [ ] All sops secrets accessible
- [ ] Overlays working

### Code Quality

- [ ] No comments restating code
- [ ] Consistent formatting throughout
- [ ] No duplicated logic
- [ ] Professional file-level headers
- [ ] All imports resolve cleanly

---

## Remember

- **ZERO BEHAVIOR CHANGES** — structure only (Phases 1–8)
- **COPY FIRST, SWITCH, THEN DELETE** — never leave broken import paths
- **CLAN-CORE IS SACRED** — do not bypass or replace it
- **LUFFY IS MINIMAL** — do not expand its import footprint
- **PORTFOLIO QUALITY** — every file should look intentional and professional
- **INTERACTIVE** — pause after each phase, report status, await permission
- **COMMIT PER PHASE** — each phase is a resumable checkpoint

You are not done until explicit approval is given.

🏴‍☠️
