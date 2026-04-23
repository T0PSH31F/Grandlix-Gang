# flake-parts/features/nixos/packages/media.nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  hasTag = tag: builtins.elem tag (config.machine.tags or [ ]);
in
{
  config = lib.mkIf (hasTag "media-server") {
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
