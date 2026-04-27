{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.features.gui.vlc = {
    enable = lib.mkEnableOption "VLC Media Player";
  };

  home = lib.mkIf config.features.gui.vlc.enable {
    home.packages = [ pkgs.vlc ];
  };
}
