# Deployment Guide (From Live Environment)

This guide explains how to deploy the NFP configuration from a live installer to fix broken systems or perform fresh installs.

## Pre-requisites
1. The repository is located at `/run/media/nixos/3520b3a2-2ca6-48cd-83a8-b0097b2ab6c5/@persist/home/t0psh31f/Clan/NFP` (or cloned into the live environment).
2. You have internet access.

## Step 1: Mount the System
We provide a helper script to automate the mounting of Luffy or Z0r0 subvolumes.

```bash
cd /run/media/nixos/3520b3a2-2ca6-48cd-83a8-b0097b2ab6c5/@persist/home/t0psh31f/Clan/NFP
./tools/mount-nfp.sh <luffy|z0r0>
```

This script will:
- Unlock the LUKS device (verified UUIDs).
- Mount the `@root` subvolume to `/mnt`.
- Mount `@nix`, `@persist`, `@log`, `@home`, and `@backup`.
- Mount the `/boot` partition.

## Step 2: Build and Install
Once mounted, run the installation command for the target machine:

```bash
nixos-install --root /mnt --flake .#<machine_name>
```

Replace `<machine_name>` with `luffy` or `z0r0`.

## Step 3: Post-Install Actions
1. **Reboot**: `reboot`
2. **Verify Persistence**: Check that `/persist` is correctly mounted and your data is safe.
3. **Z0r0 Remote Access**: If you fixed Luffy first, you can now deploy to Z0r0 via SSH if it's reachable:
   ```bash
   nixos-rebuild switch --flake .#z0r0 --target-host root@<z0r0_ip>
   ```

## Troubleshooting
- **Black Screen**: Boot into an older generation. The fixed rollback script ensures `@home` is not touched, so your data is preserved even if the system fails to boot.
- **Mount Failures**: Use `lsblk -f` to verify that the UUIDs match those in `tools/mount-nfp.sh`.
- **SOPS Errors**: Ensure your age key exists at `/persist/home/t0psh31f/.config/sops/age/keys.txt`.
