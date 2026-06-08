{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.layers.layer-10.system.peripherals.controllers;
in
{
  config = lib.mkIf cfg.enable {
    hardware.xone.enable = true;
    hardware.xpadneo.enable = true;
    services.input-remapper.enable = true;
    services.udev.packages = with pkgs; [ game-devices-udev-rules ];

    environment.systemPackages = with pkgs; [
      dualsensectl
      antimicrox
      joycond
      sixpair
    ];
  };
}
