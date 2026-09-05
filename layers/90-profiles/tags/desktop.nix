# desktop — graphical hardware features, bluetooth, automount, portals
# Tags-as-data: all config gated by tag membership.
{ config, lib, ... }:
{
  config = lib.mkIf (builtins.elem "desktop" config.machine.tags) {
    layers = {
      layer-10.system = {
        flatpak.enable = lib.mkDefault true;
        appimage.enable = lib.mkDefault true;
        peripherals = {
          automount.enable = lib.mkDefault true;
          bluetooth.enable = lib.mkDefault true;
        };
      };
      layer-30.theming = {
        cursor.enable = lib.mkDefault true;
        gtk.enable = lib.mkDefault true;
        qt.enable = lib.mkDefault true;
        sfx.enable = lib.mkDefault true;
        themes.greeter = {
          type = lib.mkDefault "noctalia-greeter";
          noctalia-greeter.session = lib.mkDefault "hyprland-uwsm";
        };
      };
      layer-40.desktop = {
        hyprland.enable = lib.mkDefault true;
        frameworks = {
          portals.enable = lib.mkDefault true;
          which-key.enable = lib.mkDefault true;
        };
        noctalia = {
          enable = lib.mkDefault true;
          backend = lib.mkDefault "hyprland";
        };
      };
      layer-50.cli.terminal-toys.enable = lib.mkDefault true;
      layer-60.gui = {
        documents.enable = lib.mkDefault true;
        feh.enable = lib.mkDefault true;
        librewolf.enable = lib.mkDefault true;
        wl_shimeji.enable = lib.mkDefault true;
        lmms.enable = lib.mkDefault true;
      };
    };
  };
}
