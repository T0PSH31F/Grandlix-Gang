{ lib, ... }: {
  imports = [
    ../../40-desktop
  ];

  features = {
    system = {
      hardware.automount.enable = lib.mkDefault true;
      hardware.bluetooth.enable = lib.mkDefault true;
      flatpak.enable = lib.mkDefault true;
    };
    desktop.frameworks.portals.enable = lib.mkDefault true;
  };
}
