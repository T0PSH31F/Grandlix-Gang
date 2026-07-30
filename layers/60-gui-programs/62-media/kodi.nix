{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.layers.layer-60.gui.kodi = {
    enable = lib.mkEnableOption "Kodi media center";
  };

  home = lib.mkIf config.layers.layer-60.gui.kodi.enable {
    home.packages = [ pkgs.kodi ];
  };
}
