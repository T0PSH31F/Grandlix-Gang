{
  config,
  lib,
  pkgs,
  osConfig ? config,
  ...
}:
let
  clanTags = osConfig.machine.tags or [ ];
in
{
  options.layers.layer-60.gui.media-packages = {
    enable = lib.mkEnableOption "Media server packages" // {
      default = builtins.elem "media" clanTags || builtins.elem "media-server" clanTags;
    };
  };

  config = lib.mkIf config.layers.layer-60.gui.media-packages.enable {
    environment.systemPackages = with pkgs; [
      deluge
      ffmpeg-full
      imagemagick
      jellyfin-desktop
      jerry
      lobster
      obs-studio
      pirate-get
      spotdl
      transmission_4
      yt-dlp
    ];
  };
}
