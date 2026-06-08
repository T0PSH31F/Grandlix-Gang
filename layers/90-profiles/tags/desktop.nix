{ lib, ... }: {
  imports = [
    ../../40-desktop
  ];

  layers = {
    layer-10.system = {
      peripherals.automount.enable = lib.mkDefault true;
      peripherals.bluetooth.enable = lib.mkDefault true;
      flatpak.enable = lib.mkDefault true;
      appimage.enable = lib.mkDefault true;
    };
    layer-40.desktop.frameworks.portals.enable = lib.mkDefault true;
    layer-50.cli.terminal-toys.enable = lib.mkDefault true;
  };
}
