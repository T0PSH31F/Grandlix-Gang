{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.layers.layer-10.system.peripherals.logitech;
in
{
  options.layers.layer-10.system.peripherals.logitech.enable =
    lib.mkEnableOption "Logitech peripherals support (Solaar)";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      logitech-udev-rules
      solaar
    ];
  };
}
