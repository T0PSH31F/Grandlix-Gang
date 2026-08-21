{ lib, ... }:
{
  imports = [
    ../../20-services
    ../../60-gui-programs
  ];

  layers.layer-20.services.config = {
    media-stack.enable = lib.mkDefault true;
  };

  layers.layer-60.gui = {
    media-packages.enable = lib.mkDefault true;
    audio.enable = lib.mkDefault true;
    mpv.enable = lib.mkDefault true;
    kodi.enable = lib.mkDefault true;
    mopidy = {
      enable = lib.mkDefault true;
      port = lib.mkDefault 6680;
      youtube.enable = lib.mkDefault true;
      podcast.enable = lib.mkDefault true;
      jellyfin = {
        enable = lib.mkDefault true;
        url = lib.mkDefault "http://localhost:8096";
      };
    };
  };
}
