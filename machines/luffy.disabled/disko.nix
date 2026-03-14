{ ... }:

{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            # REQUIRED: The 1MB BIOS boot partition for GRUB
            boot = {
              size = "1M";
              type = "EF02";
              priority = 1;
            };
            # Your main root partition (ext4 is safest, but you can use btrfs)
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
    };
  };
}
