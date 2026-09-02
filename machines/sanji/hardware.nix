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

  # Disk layout: single root partition (LVM not needed for small cloud VPS).
  # Override with disko.nix for production hosts that need declarative partitioning.
  fileSystems."/" = lib.mkDefault {
    device = "/dev/vda1"; # Adjust to match cloud provider's device naming
    fsType = "ext4";
  };

  swapDevices = lib.mkDefault [
    { device = "/dev/vda2"; }
  ];

  networking.interfaces.eth0.useDHCP = true;
}
