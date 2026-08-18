#!/usr/bin/env bash
# Helper script to mount NFP system subvolumes from a live environment.
# Usage: ./mount-nfp.sh <machine_name>

MACHINE=$1

if [[ -z "$MACHINE" ]]; then
    echo "Usage: $0 <luffy|z0r0>"
    exit 1
fi

case $MACHINE in
    luffy)
        UUID="c62695ca-f48c-4296-8e27-62f27a32c7e1"
        BOOT_UUID="8F18-74D6"
        ;;
    z0r0)
        UUID="458b615c-3ac2-4cff-98a2-c8e266bae90f"
        BOOT_UUID="3824-3E8C"
        ;;
    *)
        echo "Unknown machine: $MACHINE"
        exit 1
        ;;
esac

echo "--- LUKS Unlock ---"
if [[ ! -e /dev/mapper/crypted ]]; then
    sudo cryptsetup open /dev/disk/by-uuid/$UUID crypted
else
    echo "LUKs device already open at /dev/mapper/crypted"
fi

echo "--- Mounting Subvolumes ---"
sudo mount -o subvol=@root /dev/mapper/crypted /mnt

# Create mount points
sudo mkdir -p /mnt/{nix,persist,var/log,home,boot,backup}

# Mount secondary subvolumes
sudo mount -o subvol=@nix /dev/mapper/crypted /mnt/nix
sudo mount -o subvol=@persist /dev/mapper/crypted /mnt/persist
sudo mount -o subvol=@log /dev/mapper/crypted /mnt/var/log
sudo mount -o subvol=@home /dev/mapper/crypted /mnt/home
sudo mount -o subvol=@backup /dev/mapper/crypted /mnt/backup

echo "--- Mounting Boot Partition ---"
sudo mount /dev/disk/by-uuid/$BOOT_UUID /mnt/boot

echo "--- Mount status ---"
mount | grep /mnt

echo ""
echo "System mounted at /mnt. You can now run:"
echo "cd /run/media/nixos/3520b3a2-2ca6-48cd-83a8-b0097b2ab6c5/@persist/home/t0psh31f/Clan/NFP"
echo "nixos-install --root /mnt --flake .#$MACHINE"
