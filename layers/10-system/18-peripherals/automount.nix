{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.layers.layer-10.system.peripherals.automount;
in
{
  config = lib.mkIf cfg.enable {
    services.udisks2.enable = true;
    services.devmon.enable = true;
    services.gvfs.enable = true;

    environment.systemPackages = with pkgs; [
      udisks
    ];
  };
}
