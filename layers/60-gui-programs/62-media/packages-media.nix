{
  config,
  lib,
  pkgs,
  inputs,
  osConfig ? config,
  ...
}:
let
  clanTags = osConfig.machine.tags or [ ];
  system = pkgs.stdenv.hostPlatform.system;
in
{
  options.layers.layer-60.gui.media-packages = {
    enable = lib.mkEnableOption "Media server packages" // {
      default =
        builtins.elem "media" clanTags
        || builtins.elem "media-server" clanTags
        || builtins.elem "desktop" clanTags;
    };
  };

  config = lib.mkIf config.layers.layer-60.gui.media-packages.enable {
    environment.systemPackages = [
      pkgs.deluge
      pkgs.ffmpeg-full
      pkgs.jellyfin-desktop
      pkgs.pirate-get
      pkgs.spotdl
      pkgs.transmission_4
      pkgs.yt-dlp
      # Terminal media tools (not in nixpkgs — sourced from flake inputs)
      inputs.jerry.packages.${system}.default
      inputs.lobster.packages.${system}.default
      inputs.luffy.packages.${system}.default
    ];
  };
}
