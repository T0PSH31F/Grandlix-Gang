# Deployment Methods

> How to deploy NFP configuration changes to machines.

## Quick Reference

```bash
# From devshell (RECOMMENDED — applies to local machine)
clan machines update <machine>

# NixOS rebuild (alternative — applies + activates now)
sudo nixos-rebuild switch --flake .#<machine>

# Remote deploy (e.g., luffy from z0r0)
sudo nixos-rebuild switch --flake .#luffy --target-host root@100.80.146.120

# Boot-only (for chroot recovery)
nixos-rebuild boot --flake .#z0r0
```

## 1. Clan Machines Update (Recommended)

The primary deployment method. Must be run from within the NFP devshell.

```bash
# Enter devshell
cd /home/t0psh31f/Clan/NFP
direnv allow  # if not already in devshell

# Deploy to local machine
clan machines update z0r0

# Deploy to remote
clan machines update luffy
```

**What it does**: Builds the config, copies to target, sets up boot entry,
optionally activates services. Does NOT run `nixos-rebuild switch` directly.

**Why it matters**: Handles clan-core vars (secrets, WiFi passwords) that
`nixos-rebuild` alone misses.

## 2. NixOS Rebuild (Direct)

```bash
# Build + activate now
sudo nixos-rebuild switch --flake .#z0r0

# Build + update bootloader only (no activation — safe in chroot)
sudo nixos-rebuild boot --flake .#z0r0
```

### When to use instead of clan

| Scenario | Method |
|----------|--------|
| Local activation | `clan machines update` (preferred) or `nixos-rebuild switch` |
| Recovery from live USB | `nixos-rebuild boot --flake .#z0r0` in chroot |
| Remote machine | `--target-host` or `clan machines update` |
| Testing without activation | `nixos-rebuild build --flake .#z0r0` |

## 3. Remote Deployment

From z0r0 to luffy via Tailscale:

```bash
# SSH works if Tailscale/Headscale is up
sudo nixos-rebuild switch --flake .#luffy --target-host root@100.80.146.120

# Or use clan
clan machines update luffy
```

## 4. Live USB Recovery

```bash
# 1. Mount the system
./tools/mount-nfp.sh z0r0   # or luffy

# 2. Chroot
sudo nixos-enter --root /mnt

# 3. Rebuild (boot, not switch)
cd /persist/home/t0psh31f/Clan/NFP
nixos-rebuild boot --flake .#z0r0
exit

# 4. Reboot
sudo umount -R /mnt
sudo cryptsetup close cryptroot
reboot
```

**Full details**: [deploy-from-live.md](deploy-from-live.md)

## 5. Flake Check (Validation Before Deploy)

```bash
# Full check (builds all outputs)
nix flake check

# Targeted nixvim eval (fast — checks just the editor config)
nix eval '.#nixosConfigurations.z0r0.config.home-manager.users.t0psh31f.programs.nixvim.enable' --json

# Build-specific derivation
nix build '.#nixosConfigurations.z0r0.config.system.build.toplevel'
```

## Important Notes

- **Never run `nix-store --gc`** without running `nixos-rebuild boot` first
  (util-linux broken symlink bug — will delete boot-critical mount binaries).
  Use `nix-safe-gc` instead.
- **`clan machines update`** must be run from the devshell with `clan-cli`
  available. `direnv allow` auto-enters the devshell.
- **SOPS**: If clan vars or secrets fail, ensure your age key is at
  `~/.config/sops/age/keys.txt`.
