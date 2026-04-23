# MASTER REFACTORING PROMPT: NFP Layered Architecture Migration

## CRITICAL MISSION REQUIREMENTS

You are performing an **INTERACTIVE** structural refactor of the NFP (Nix Flake Pirates) repository from its current feature-based organization to a layered architecture with clan-core tag-based composition. This is a production-critical operation.

**SUCCESS CRITERIA:**
1. All existing functionality preserved (zero behavior changes)
2. `nix flake check` passes without errors
3. All three machines (luffy, nami, z0r0) build successfully
4. Clean, professional, production-ready code quality
5. Git workflow followed exactly as specified
6. Approval obtained before merging to main

---

## GIT WORKFLOW (NON-NEGOTIABLE)

**STEP 1: Branch Management**
```bash
# Create backup of main
git branch backup-main-$(date +%Y%m%d-%H%M%S)

# Create and switch to refactor branch
git checkout -b refactor/layered-architecture
```

**STEP 2: Make Changes**
- All refactoring work happens on `refactor/layered-architecture` branch
- Commit logically related changes together with clear messages
- DO NOT push to main until explicitly approved

**STEP 3: Validation (REQUIRED BEFORE REQUESTING APPROVAL)**
```bash
# Must pass ALL of these:
git add .
nix flake check
nix build .#nixosConfigurations.luffy.config.system.build.toplevel
nix build .#nixosConfigurations.nami.config.system.build.toplevel
nix build .#nixosConfigurations.z0r0.config.system.build.toplevel
```

**STEP 4: Approval Gate**
- Present summary of changes
- Show validation results
- Request explicit approval: "Ready to merge to main and deploy to z0r0?"
- STOP and WAIT for approval

**STEP 5: Merge & Deploy (ONLY AFTER APPROVAL)**
```bash
git checkout main
git merge --no-ff refactor/layered-architecture -m "Refactor: Migrate to layered architecture with clan-core tags"
nixos-rebuild switch --flake .#z0r0
```

---

## REPOSITORY INFORMATION

**Repository URL:** https://github.com/T0PSH31F/NFP
**Primary User:** t0psh31f
**Deployment Target:** z0r0 (primary workstation)

**Machines:**
- **luffy**: VPS server (headless, AI, web services, monitoring)
- **nami**: Laptop/workstation (desktop environment, mobile support)
- **z0r0**: Primary workstation (development, gaming, full desktop)

---

## CURRENT STRUCTURE

```
NFP/
├── flake.nix                           # Clan-core integrated flake
├── flake-parts/
│   ├── clan-inventory.nix              # Clan inventory with instances
│   ├── features/
│   │   ├── nixos/                      # System-level features
│   │   │   ├── default.nix
│   │   │   ├── appimage.nix
│   │   │   ├── desktop/
│   │   │   ├── flatpak.nix
│   │   │   ├── gaming.nix
│   │   │   ├── impermanence.nix
│   │   │   ├── mobile-support.nix
│   │   │   ├── packages/               # Package groups (base, desktop, ai, dev, media, pentest)
│   │   │   └── virtualization.nix
│   │   └── home/                       # Home-manager features (keep mostly as-is)
│   ├── services/                       # Service definitions
│   ├── system/                         # System configs
│   ├── hardware/                       # Hardware configs
│   ├── themes/                         # System themes
│   └── users/                          # User definitions
├── machines/{luffy,nami,z0r0}/         # Machine definitions
├── clan-services/                      # Custom clan services
└── clan.nix                            # Main clan configuration
```

---

## TARGET STRUCTURE

```
NFP/
├── flake.nix                           # Updated with mkMachineFromTags
├── modules/                             # NEW: Feature layers
│   ├── 00-foundation/                  # Nix, boot, locale, networking
│   ├── 10-system/                      # Containers, virtualization, filesystems
│   ├── 20-services/                    # Web, databases, monitoring, AI
│   ├── 30-desktop/                     # Wayland compositors, theming
│   ├── 40-applications/                # Editors, browsers
│   └── 50-development/                 # Languages, dev tools
├── profiles/                           # NEW: Tag-based compositions
│   ├── tags/                           # server, workstation, laptop, ai-worker, etc.
│   └── roles/                          # backup-server, monitoring-server, web-server
├── lib/
│   └── mkMachineFromTags.nix           # NEW: Auto-imports profiles based on tags
├── machines/                           # Minimal host-specific overrides only
├── clan/
│   ├── inventory.nix                   # Clan inventory with tags
│   ├── services/                       # Clan service definitions
│   └── secrets/
└── home/                               # Home-manager (preserve existing structure)
```

---

## MACHINE TAG ASSIGNMENTS

### Luffy (VPS Server)
**Tags:** `["server", "ai", "monitoring", "backup-server", "web-server"]`
**Key Services:** Ollama, Qdrant, Nextcloud, Immich, Vaultwarden, Caddy, Postgres
**Profile Imports:**
- `profiles/tags/server.nix`
- `profiles/tags/ai-worker.nix`
- `profiles/roles/web-server.nix`
- `profiles/roles/backup-server.nix`

### Nami (Laptop)
**Tags:** `["laptop", "workstation", "desktop", "backup", "mobile"]`
**Profile Imports:**
- `profiles/tags/laptop.nix`
- `profiles/tags/workstation.nix`
- `profiles/tags/backup-client.nix`

### Z0r0 (Primary Workstation)
**Tags:** `["workstation", "desktop", "development", "gaming", "backup"]`
**Profile Imports:**
- `profiles/tags/workstation.nix`
- `profiles/tags/backup-client.nix`

---

## MIGRATION MAPPINGS

**CRITICAL RULE: PHASE 1-8 OPTION PRESERVATION.**
During the structural move (Phases 1-8), ONLY move the files to the new folder structure and update the `imports = []` paths. Keep the actual Nix options (like `config.desktop.vicinae.enable`) exactly as they currently are. Do NOT rename them to `config.layers...` yet. We will perform a dedicated Option Schema Migration in Phase 9.

### Foundation Layer (00-foundation/)
**Source → Target:**
- `flake-parts/system/nix.nix` → `modules/00-foundation/nix-config.nix`
- `flake-parts/system/boot.nix` → `modules/00-foundation/boot.nix`
- `flake-parts/system/locale.nix` → `modules/00-foundation/locale.nix`
- `flake-parts/system/networking.nix` → `modules/00-foundation/networking.nix`

**Example:**
```nix
# modules/00-foundation/default.nix
{ ... }: {
  imports = [
    ./nix-config.nix
    ./boot.nix
    ./locale.nix
    ./networking.nix
  ];
}

# modules/00-foundation/nix-config.nix
{ ... }: {
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ "https://cache.nixos.org" "https://nix-community.cachix.org" ];
  };
  nixpkgs.config.allowUnfree = true;
}
```

### System Layer (10-system/)
**Source → Target:**
- `flake-parts/features/nixos/virtualization.nix` → Split into:
  - `modules/10-system/containers/docker.nix`
  - `modules/10-system/containers/podman.nix`
  - `modules/10-system/virtualization/qemu.nix`
  - `modules/10-system/virtualization/libvirt.nix`

**Example:**
```nix
# modules/10-system/containers/podman.nix
{ config, lib, pkgs, ... }: {
  options.layers.containers.podman = {
    enable = lib.mkEnableOption "Podman container runtime";
    dockerCompat = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf config.layers.containers.podman.enable {
    virtualisation.podman = {
      enable = true;
      autoPrune.enable = true;
      dockerCompat = config.layers.containers.podman.dockerCompat;
      dockerSocket.enable = config.layers.containers.podman.dockerCompat;
    };
    virtualisation.oci-containers.backend = "podman";
  };
}
```

### Services Layer (20-services/)
**Source → Target:**
- `flake-parts/services/ai/` → `modules/20-services/ai/`
- `flake-parts/services/infrastructure/` → Extract to appropriate modules
- Web, databases, monitoring → Separate modules

**Tag-Aware Example:**
```nix
# modules/20-services/monitoring/prometheus.nix
{ config, lib, pkgs, machineTags ? [], ... }: {
  options.layers.monitoring.prometheus = {
    enable = lib.mkEnableOption "Prometheus monitoring";
  };

  config = lib.mkIf config.layers.monitoring.prometheus.enable {
    services.prometheus.exporters.node = {
      enable = true;
      enabledCollectors = [ "systemd" "processes" ];
    };
    
    # Server role for machines tagged "monitoring-server"
    services.prometheus = lib.mkIf (builtins.elem "monitoring-server" machineTags) {
      enable = true;
      port = 9090;
    };
  };
}
```

---

## PROFILE IMPLEMENTATIONS

### Server Profile
```nix
# profiles/tags/server.nix
{ config, lib, pkgs, ... }: {
  imports = [
    ../../modules/00-foundation
    ../../modules/10-system/containers/podman.nix
    ../../modules/20-services/web/caddy.nix
    ../../modules/20-services/databases/postgres.nix
    ../../modules/20-services/monitoring/prometheus.nix
  ];

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  boot.kernelParams = [ "quiet" ];
  layers.monitoring.prometheus.enable = true;
  networking.firewall.enable = true;
  services.fail2ban.enable = true;
}
```

### Workstation Profile
```nix
# profiles/tags/workstation.nix
{ config, lib, pkgs, ... }: {
  imports = [
    ../../modules/00-foundation
    ../../modules/10-system/containers/podman.nix
    ../../modules/30-desktop
    ../../modules/40-applications/editors/vscode.nix
    ../../modules/40-applications/browsers/brave.nix
    ../../modules/50-development/languages/nix.nix
    ../../modules/50-development/tools/git.nix
  ];

  services.xserver.enable = true;
  services.pipewire.enable = true;
  programs.direnv.enable = true;
  layers.desktop.enable = true;
}
```

---

## LIB/MKMACHINEFROMTAGS

```nix
# lib/mkMachineFromTags.nix
{ lib, ... }:
{ machineName, inventory }:
let
  machineConfig = inventory.machines.${machineName} or {};
  tags = machineConfig.tags or [];
  
  tagToProfile = tag:
    let profilePath = ../profiles/tags/${tag}.nix;
    in if builtins.pathExists profilePath
       then [ profilePath ]
       else lib.warn "Profile for tag '${tag}' not found" [];
  
  profileImports = lib.flatten (map tagToProfile tags);
in {
  imports = profileImports ++ [ ./machines/${machineName} ];
  _module.args.machineTags = tags;
  networking.hostName = lib.mkDefault machineName;
}
```

**Integration in flake.nix:**
```nix
let
  mkMachine = machineName: lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { 
      inherit inputs clan-core;
      inventory = config.clan.inventory;
    };
    modules = [
      (import ./lib/mkMachineFromTags.nix { inherit lib; } {
        inherit machineName;
        inventory = config.clan.inventory;
      })
    ];
  };
in {
  nixosConfigurations = {
    luffy = mkMachine "luffy";
    nami = mkMachine "nami";
    z0r0 = mkMachine "z0r0";
  };
}
```

---

## UPDATED CLAN INVENTORY

```nix
# flake-parts/clan-inventory.nix or clan/inventory.nix
{ ... }: {
  clan.inventory = {
    machines = {
      luffy = {
        tags = [ "server" "ai" "monitoring" "backup-server" "web-server" ];
        deploy.targetHost = "luffy.tail-net.ts.net";
      };
      nami = {
        tags = [ "laptop" "workstation" "desktop" "backup" "mobile" ];
        deploy.targetHost = "nami.local";
      };
      z0r0 = {
        tags = [ "workstation" "desktop" "development" "gaming" "backup" ];
        deploy.targetHost = "z0r0.local";
      };
    };

    instances.sshd-cluster = {
      module = { name = "sshd"; input = "clan-core"; };
      roles = {
        server.tags = [ "server" "workstation" "laptop" ];
        client.tags = [ "server" "workstation" "laptop" ];
      };
    };

    instances.backup = {
      module = { name = "borgbackup"; input = "clan-core"; };
      roles = {
        client.tags = [ "backup" ];
        server.machines.luffy = {};
      };
    };

    instances.monitoring = {
      module = { name = "prometheus"; input = "clan-core"; };
      roles = {
        server.machines.luffy = {};
        target.tags = [ "server" "workstation" ];
      };
    };
  };
}
```

---

## CODE QUALITY REQUIREMENTS

### 1. Eliminate Redundant Comments
**BEFORE:**
```nix
{ config, lib, pkgs, ... }: {
  # Enable docker
  virtualisation.docker.enable = true;
  # Set docker to use btrfs
  virtualisation.docker.storageDriver = "btrfs";
}
```

**AFTER:**
```nix
{ config, lib, pkgs, ... }: {
  virtualisation.docker = {
    enable = true;
    storageDriver = "btrfs";
  };
}
```

**Rules:**
- NO comments that restate code
- ONLY add comments for non-obvious decisions, workarounds, or security considerations
- Keep section headers minimal

### 2. Eliminate Code Duplication
- Repeated patterns → Shared functions in `lib/`
- Repeated imports → Profile composition
- Repeated service configs → Extract to layers

### 3. Consistent Formatting
- Use `nixpkgs-fmt` or `alejandra`
- Alphabetize imports where logical
- Use `mkDefault`, `mkForce`, `mkIf` appropriately
- 2-space indentation

### 4. Clear Module Structure (Target for Phase 9)
In Phase 9, after the physical structure is validated, you will rewrite the configuration schemas to match the new layered namespace for maximum readability:
```nix
{ config, lib, pkgs, ... }: {
  options.layers.<layer>.<module> = {
    enable = lib.mkEnableOption "description";
  };

  config = lib.mkIf config.layers.<layer>.<module>.enable {
    # Configuration
  };
}
```

---

## VALIDATION CHECKLIST

Before requesting approval:

### Build Validation
```bash
✓ nix flake check
✓ nix build .#nixosConfigurations.luffy.config.system.build.toplevel
✓ nix build .#nixosConfigurations.nami.config.system.build.toplevel
✓ nix build .#nixosConfigurations.z0r0.config.system.build.toplevel
```

### Structure Validation
```bash
✓ All modules/ directories created
✓ All profiles/ created
✓ lib/mkMachineFromTags.nix implemented
✓ machines/ reduced to host-specific only
✓ clan.inventory updated
```

### Code Quality
```bash
✓ No unnecessary comments
✓ No duplicated logic
✓ Consistent formatting
✓ All imports resolve
✓ Old structure cleaned up
```

### Functionality
```bash
✓ All services preserved
✓ All hardware configs preserved
✓ All user configs preserved
✓ All secrets accessible
✓ Home-manager configs work
```

---

## EXECUTION PHASES

**Phase 1: Setup (5 min)**
- Create backup + refactor branches
- Create directory structure
- STOP and await permission to proceed.

**Phase 2: Foundation & System (30 min)**
- Extract foundation modules
- Extract system modules
- Test: `git add . && nix flake check`
- STOP and report status. Await permission to proceed.

**Phase 3: Services (45 min)**
- Extract service modules
- Make tag-aware
- Test: `git add . && nix flake check`
- STOP and report status. Await permission to proceed.

**Phase 4: Desktop & Apps (30 min)**
- Extract desktop/app modules
- Test: `git add . && nix flake check`
- STOP and report status. Await permission to proceed.

**Phase 5: Profiles & Tags (45 min)**
- Create profiles
- Implement mkMachineFromTags
- Test: `git add . && nix flake check`
- STOP and report status. Await permission to proceed.

**Phase 6: Machines (30 min)**
- Refactor machine configs
- Test: `git add .` then build all machines
- STOP and report status. Await permission to proceed.

**Phase 7: Inventory (20 min)**
- Update clan inventory
- Test: `git add . && nix flake check`
- STOP and report status. Await permission to proceed.

**Phase 8: Cleanup (30 min)**
- Remove old structure
- Update documentation
- Final validation of structure
- STOP and report status. Await permission to proceed.

**Phase 9: Option Schema Migration (60 min)**
- Methodically rename all `options` and references to match the new `options.layers.<layer>.<module>` schema across all files.
- Ensure all profiles and modules are updated to use the new namespaces.
- Test: `git add . && nix flake check`
- STOP and report status. Await permission to proceed.

**Phase 10: Approval & Deploy**
- Present summary
- WAIT for final approval
- Merge + deploy to z0r0

---

## ERROR HANDLING

**If nix flake check fails:**
1. Read error carefully
2. Fix the issue
3. DO NOT proceed
4. Re-validate

**If machine build fails:**
1. Identify error
2. Check imports/options
3. Verify hardware.nix
4. Fix and re-validate

**If uncertain:**
1. Add TODO comment
2. Document uncertainty
3. Continue with clear mappings
4. Flag for review

---

## APPROVAL GATE

After validation, present:
1. **Summary:** Files moved/created/deleted, key changes
2. **Validation Results:** All check outputs
3. **Structure:** Tree of new directories
4. **Git Status:** Branch confirmation

**Wait for:** "approved" or "deploy" response

**Then execute:**
```bash
git checkout main
git merge --no-ff refactor/layered-architecture
nixos-rebuild switch --flake .#z0r0
```

---

## REMEMBER

- **ZERO BEHAVIOR CHANGES** - Structure only
- **PROFESSIONAL QUALITY** - Production-ready code
- **VALIDATION REQUIRED** - All checks pass
- **APPROVAL REQUIRED** - Do not merge without permission
- **INTERACTIVE EXECUTION** - Pause after each phase to run `git add .` and `nix flake check`, then report status and await permission to proceed.

You are not done until explicit approval is given.

Good luck! 🏴‍☠️
