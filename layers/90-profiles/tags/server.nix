{ lib, ... }:
{
  imports = [
    ../../10-system/11-foundation
    ../../20-services/21-networking
  ];

  layers.layer-20.services.config = {
    adguard.enable = lib.mkDefault true;
    monitoring.enable = lib.mkDefault true;
    tailscale.enable = lib.mkDefault true;
  };

  layers.layer-20.services.backups.restic.enable = lib.mkDefault true;
}
