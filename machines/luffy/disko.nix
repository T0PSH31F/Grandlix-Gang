{ ... }:

{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/nvme0n1"; # UPDATE THIS TO MATCH YOUR DISK (e.g. /dev/sda, /dev/nvme0n1)
      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = "4G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "defaults"
                "umask=0077"
              ];
            };
          };
          swap = {
            size = "32G"; # Match RAM for hibernate support
            content = {
              type = "luks";
              name = "swap_crypted_nvme";
              passwordFile = "/tmp/secret.key";
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = true;
              };
            };
          };
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "crypted_nvme";
              passwordFile = "/tmp/secret.key";
              settings = {
                allowDiscards = true;
                bypassWorkqueues = true;
              };
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];

                subvolumes = {
                  "@root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@persist" = {
                    mountpoint = "/persist";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@backup" = {
                    mountpoint = "/backup";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@log" = {
                    mountpoint = "/var/log";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
