{ lib, ... }:
{
  imports = [
    ../../60-gui-programs
  ];
  layers.layer-60.gui.gaming.enable = lib.mkDefault true;
}
