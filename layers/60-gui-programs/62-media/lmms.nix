# LMMS — Linux MultiMedia Studio (Digital Audio Workstation)
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.layers.layer-60.gui.lmms;
in
{
  options.layers.layer-60.gui.lmms = {
    enable = mkEnableOption "LMMS — Linux MultiMedia Studio digital audio workstation";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.lmms-full ];
  };
}
