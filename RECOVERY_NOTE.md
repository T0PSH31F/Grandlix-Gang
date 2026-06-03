# NixOS Recovery Note - June 2, 2026

## Context
Machine `z0r0` was experiencing a persistent boot failure (service cascade). Primary causes identified:
1. **AdGuard Home**: Permission denied on config/timing issue with impermanence.
2. **n8n**: `SQLITE_READONLY` error due to `DynamicUser` mismatching persistent storage permissions.
3. **ZeroTier**: Failing due to `sops-nix` secrets not being ready.

## Work Completed (Applied to Disk)
The following files at `/mnt/persist/home/t0psh31f/Clan/NFP` have been updated:
- `layers/20-services/21-networking/adguard.nix`: Added `persist.mount` dependency and infinite restarts.
- `layers/20-services/27-automation/n8n.nix`: Disabled `DynamicUser`, added static `n8n` user, added infinite restarts.
- `machines/z0r0/default.nix`: Removed ZeroTier systemd overrides.
- `clan.nix`: Removed ZeroTier instance; added `wifi` instance for `z0r0` and `luffy`.

## System Environment
- **LUKS**: Already open as `cryptroot`.
- **Mounts**: 
  - `@root` -> `/mnt`
  - `@home` -> `/mnt/home`
  - `@log` -> `/mnt/var/log`
  - `@persist` -> `/mnt/persist`
  - `@nix` -> `/mnt/nix`
  - `/dev/nvme0n1p1` -> `/mnt/boot`

## Final Steps (To be run by next AI/User)
1. **Set WiFi Secrets**:
   ```bash
   sudo git config --global --add safe.directory /mnt/persist/home/t0psh31f/Clan/NFP
   export SOPS_AGE_KEY_FILE=/mnt/persist/home/t0psh31f/.config/sops/age/keys.txt
   cd /mnt/persist/home/t0psh31f/Clan/NFP
   nix run git+https://git.clan.lol/clan/clan-core -- vars set wifi.home.network-name --value "The bases been had!"
   nix run git+https://git.clan.lol/clan/clan-core -- vars set wifi.home.password --value "CapitalAssword!"
   ```

2. **Rebuild via Chroot**:
   ```bash
   sudo mount --bind /dev /mnt/dev
   sudo mount --bind /proc /mnt/proc
   sudo mount --bind /sys /mnt/sys
   sudo chroot /mnt /nix/var/nix/profiles/system/sw/bin/bash -c "source /etc/profile; export PATH=\$PATH:/run/current-system/sw/bin; nixos-rebuild switch --flake /persist/home/t0psh31f/Clan/NFP#z0r0 --impure"
   ```

3. **Reboot**:
   ```bash
   sudo reboot
   ```
