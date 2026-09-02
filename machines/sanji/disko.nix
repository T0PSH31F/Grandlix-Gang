# disko.nix — Minimal disk layout for Alibaba ExCS cloud VPS.
# Matches the existing Alibaba partition table:
#   nvme0n1p1 (1MB, BIOS-GPT) | nvme0n1p2 (200MB, EFI) | nvme0n1p3 (root, ext4)
# Re-use the existing EFI partition and root partition without reformatting
# the entire disk — nixos-anywhere will install NixOS onto the existing root.
{
  disko.devices.disk.nvme0 = {
    device = "/dev/nvme0n1";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        # Preserve the existing BIOS-GPT partition (1MB)
        bios-grub = {
          type = "EF02";
          size = "1M";
        };
        # EFI partition — reuse existing 200MB vfat partition
        ESP = {
          type = "EF00";
          size = "200M";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
          };
        };
        # Root filesystem — rest of disk
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
