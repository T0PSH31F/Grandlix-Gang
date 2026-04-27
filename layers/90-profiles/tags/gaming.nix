{ lib, ... }: {
  imports = [
    ../../60-gui-programs
  ];
  features.gui.gaming.enable = lib.mkDefault true;
}
