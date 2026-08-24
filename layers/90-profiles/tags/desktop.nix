{ lib, ... }:
{
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
    layer-30.theming.themes.greeter = {
      type = lib.mkDefault "noctalia-greeter";
      noctalia-greeter.session = lib.mkDefault "hyprland-uwsm";
    };
    layer-40.desktop = {
      frameworks.portals.enable = lib.mkDefault true;
      noctalia.backend = lib.mkDefault "hyprland";
    };
    layer-50.cli.terminal-toys.enable = lib.mkDefault true;
    layer-60.gui.documents.enable = lib.mkDefault true;
    layer-60.gui.wl_shimeji.enable = lib.mkDefault true;
  };
}
