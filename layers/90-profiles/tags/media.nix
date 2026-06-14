{ lib, ... }:
{
  imports = [
    ../../20-services
    ../../60-gui-programs
  ];
  layers.layer-60.gui = {
    media-packages.enable = lib.mkDefault true;
    audio.enable = lib.mkDefault true;
    mpv.enable = lib.mkDefault true;
  };
}
