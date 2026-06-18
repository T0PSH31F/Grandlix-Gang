{ ... }:
{
  imports = [
    ./calibre-web.nix
    ./download-clients.nix
    ./jellyfin.nix
    ./komga.nix
    ./media-stack.nix
    ./prowlarr.nix
    ./radarr.nix
    ./recyclarr.nix
    ./sonarr.nix
    ./usenet.nix
  ];
}