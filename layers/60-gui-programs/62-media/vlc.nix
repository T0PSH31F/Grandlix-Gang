{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.layers.layer-60.gui.vlc = {
    enable = lib.mkEnableOption "VLC Media Player";
  };

  home = lib.mkIf config.layers.layer-60.gui.vlc.enable {
    home.packages = [ pkgs.vlc ];
  };
}
