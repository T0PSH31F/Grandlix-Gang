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
  options.features.gui.media-packages = {
    enable = lib.mkEnableOption "Media server packages" // {
      default = builtins.elem "media" clanTags || builtins.elem "media-server" clanTags;
    };
  };

  nixos = lib.mkIf config.features.gui.media-packages.enable {
    environment.systemPackages = with pkgs; [
      deluge
      ffmpeg-full
      imagemagick
      obs-studio
      transmission_4
      pirate-get 
      yt-dlp
    ];
  };
}
