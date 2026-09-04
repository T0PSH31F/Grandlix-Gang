# hardware.nix — stub for cloud VPS (Alibaba Elastic Compute / Oracle ARM).
# This file is intentionally minimal: cloud VMs expose generic virtio hardware;
# the real hardware configuration comes from the cloud provider's NixOS image,
# not from nixos-generate-config. Adjust disk/network if the hosting provider
# does not use standard virtio.
{
  lib,
  ...
}:
{
  # Platform — Alibaba ExCS: x86_64-linux; Oracle ARM: aarch64-linux.
  # Change to lib.systems.aarch64-linux when targeting Oracle Ampere A1.
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Systemd/initrd: cloud instances use generic virtio buses.
  boot = {
    initrd.availableKernelModules = [
      "virtio_pci"
      "virtio_scsi"
      "virtio_blk"
      "xhci_pci"
    ];
    kernelModules = [ ];
  };

  # Disk layout: single root partition on NVMe (standard Alibaba ExCS layout).
  # The Alibaba image uses /dev/nvme0n1p1 (1MB BIOS), p2 (200MB EFI), p3 (root).
  # No disko — provisioning handled by nixos-anywhere or nixos-install.
  fileSystems."/" = lib.mkDefault {
    device = "/dev/nvme0n1p3";
    fsType = "ext4";
  };

  fileSystems."/boot" = lib.mkDefault {
    device = "/dev/nvme0n1p2";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ ];
  networking.interfaces.eth0.useDHCP = true;
}
