# Grandlix-Gang Context & Refactoring Guide (CLAN_CONTEXT.md)

## 1. Project Overview

**Repo:** `github:T0PSH31F/Grandlix-Gang`
**Owner:** T0psh31f (Erik)
**Location:** Los Angeles, CA
**Framework:** Clan (Sovereign Infrastructure on NixOS)
**Core Philosophy:** Permanent storage persistence (`/persist`), tmpfs root (Impermanence), Sops-Nix Secrets, Flake-parts, Tag-based Module Injection.

## 1. Project Mandate: The "Tagged" Architecture

We are refactoring this NixOS/Clan project to use a **Tag-Based Package Injection System**.
Instead of monolithic `environment.systemPackages`, machines declare a list of "tags" (e.g., `["desktop" "gaming"]`), and the module system conditionally imports the relevant suites.

* **Old Way:** Hardcoded `roles = []` or manual imports.
* **New Way:** Machines declare `clan.tags = [ "desktop" "ai-ml" ];` (defined in tags profiles or machine configurations), and modules are conditionally imported.

### The "Tag" Logic

We use a conditional merge strategy.

* **Input:** `clan.tags = [ "desktop" "ai-ml" ];` (defined in `inventory/machines/machine-name.nix` or tags profiles)
* **Logic:** `lib.mkIf (hasTag "desktop") { ... }`

### Directory Structure (Strict Adherence)

The agent must enforce this directory structure:

```text
packages/
├── core/                  # Base system (git, curl, htop, persistence, sops) - Always Imported
│   └── default.nix
├── desktop/               # Tag: "desktop"
│   ├── default.nix        # Aggregator (Hyprland + SDDM)
│   ├── hyprland.nix       # Sub-Tag: "hyprland"
│   ├── sddm.nix           # Sub-Tag: "sddm"
│   ├── niri.nix           # Tag: "niri"
│   ├── fonts.nix          # Tag: "fonts"
│   ├── themes.nix         # Tag: "themes" (Lainframe, Sonic Cursor)
│   └── fun-tools.nix      # Tag: "fun-tools"
├── development/           # Tag: "dev"
├── pentest/               # Tag: "pentest"
│   ├── default.nix
│   ├── wifi.nix           # Tag: "wifi-pentest"
│   └── recon.nix          # Tag: "recon"
├── gaming/                # Tag: "gaming"
│   ├── default.nix
│   └── steam.nix
├── ai/                    # Tag: "ai-server" or "ai-heavy"
│   ├── default.nix
│   └── ollama.nix
├── cache/                 # Tag: "binary-cache"
│   └── harmonia.nix       # Tag: "binary-cache" (Port 5000)
├── hardware/              # Tags: "nvidia", "amd-gpu", "intel"
│   ├── nvidia.nix         # Tag: "nvidia"
│   └── intel.nix          # Tag: "intel"
└── virtualization/        # Tag: "virtualization"
```

## 2. Implementation Reference (Copy-Paste Ready)

### A. The Module Logic (layers/tags.nix)

The agent should create this module to enable the tag system.

```nix
let
  inherit (config.lib.clan) hasTag hasAnyTag;
in
lib.mkMerge [
  (lib.mkIf (hasTag "desktop") {
    environment.systemPackages = with pkgs; [ firefox kitty wofi pavucontrol ];
  })
  (lib.mkIf (hasTag "desktop" && hasTag "hyprland") {
    imports = [ ./hyprland.nix ];
  })
]
```

### B. Disko + ZFS Encryption (Reference: docs.clan.lol)

Constraint: Encryption keys must be managed via Clan Vars to allow unattended booting or remote unlocking.

#### 1. Define the Secret Generator (vars/per-machine/machine/secrets.nix)

```nix
clan.core.vars.generators.zfs_key = {
  files."zfs.key" = {
    neededFor = "partitioning";
    secret = true;
  };
  runtimeInputs = [ pkgs.coreutils ];
  script = ''
    openssl rand -hex 32 | tr -d '\n' > $out/zfs.key
  '';
};
```

#### 2. Disko Config (disk-config.nix)

```nix
{
  disko.devices.disk.main.content = {
    type = "gpt";
    partitions = {
      zfs = { size = "100%"; content = { type = "zfs"; pool = "zroot"; }; };
    };
  };
  disko.devices.zpool.zroot = {
    type = "zpool";
    options.feature@encryption = "on";
    options.keylocation = "file://${config.clan.core.vars.generators.zfs_key.files."zfs.key".path}";
    options.keyformat = "hex";
  };
}
```

### C. Clan Services (Reference)

When enabling standard services, prefer `clan.core.services.*` over `services.*` when available, as they handle firewalling and Zerotier DNS automatically.

* **Syncthing**
* **Backups**
* **Networking**

Clan also has native services/options for admin, certificates, coredns, matrix-synapse, monitoring, sshd, trusted-nix-caches, wireguard, users, and packages.

> [!NOTE]
> Packages should be defined with conditional imports for easily enabling sets/suites based on the dendritic pattern, and packages already defined need to be restructured into this format.

* All of which can be found and should be referenced at [docs.clan.lol](https://docs.clan.lol/)

## 3. Machine Inventory & Tag Assignments

### z0r0 (Primary Hub)

* **Hardware**: LG Gram 17Z90Q, Intel i7-1260P, 16GB RAM.
* **Network**: 192.168.1.100 (Static).
* **Target Tags**: `clan.tags = [ "desktop" "ai-server" "binary-cache" "database" "dns-server" "intel" ];`
* **Persistence**: Critical: `/persist/home/t0psh31f`, `/persist/var/lib/{ollama,postgres,harmonia}`.

### nami (Media/Storage)

* **Hardware**: LUKS-encrypted Btrfs.
* **Network**: DHCP.
* **Target Tags**: `clan.tags = [ "media-server" "download-server" ];`
* **Storage**: Mounts `/srv/media` via Btrfs subvolume `@media`.

### luffy (Future Gaming)

* **Hardware**: Unknown
* **Network**: Unknown
* **Target Tags**: `clan.tags = [ "desktop" "gaming" "ai-heavy" "nvidia" ];`

## 4. Implementation Rules (Agent Anti-Hallucination)

* **Impermanence First**: In `packages/core/default.nix`, ensure `environment.persistence."/persist"` is configured. Do not break boot by losing SSH keys.
* **Clan Secrets**: Use `clan.core.vars` and `sops-nix`. Secrets are at `~/Grandlix-Gang/secrets/`.
* **Harmonia Key**: `secrets/harmonia.yaml`
* **Postgres**: `secrets/postgres.yaml`
* **Module Logic**: Create `layers/tags.nix` to define `options.clan.tags`.
* **Use**: `lib.mkIf (hasTag "ai-server") { services.ollama.enable = true; }`
* **Networking**:
  * Tailscale is essential for the mesh (100.x.x.x).
  * Open firewall ports defined in "Inventory" (e.g., 5000 for Harmonia, 11434 for Ollama).

## 5. Deployment Reference

* **Update**: `clan machines update` (Preferred over `nixos-rebuild`).
* **Secrets**: `clan secrets upload <machine>`.

## Refactoring Strategy for Agent

* **Scaffold**: Create the `packages/` directory structure first.
* **Move & Tag**: Move existing packages from `configuration.nix` into the relevant `packages/category/default.nix`.
* **Conditionals**: Wrap every package group in `lib.mkIf (hasTag "X")`.
* **Hardware**: Create `packages/hardware/nvidia.nix` containing `hardware.opengl`, `services.xserver.videoDrivers`, and `nvidia-container-toolkit`.
* **Verify**: Ensure `flake.nix` imports the new module system.

Make sure you understand everything and that everything builds and works in accordance with the docs! [docs.clan.lol](https://docs.clan.lol/) I will leave to your better judgement if you can come up with better/more accurate architectural than I have suggested based on your research and understanding of clan. Also make sure to preserve our desktop configurations and noctalia-sh which should be importable with desktop/hyprland/niri tags. This is a reorganization and refactoring though we're restructuring try to preserve currently defined functionality and configurations as much as possible.
