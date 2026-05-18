{
  config,
  lib,
  pkgs,
  osConfig ? config,
  ...
}:
let
  clanTags = osConfig.machine.tags or [ ];
in
{
  options.layers.layer-60.gui.desktop-packages = {
    enable = lib.mkEnableOption "Common desktop packages" // {
      default = builtins.elem "desktop" clanTags || builtins.elem "workstation" clanTags;
    };
  };

  config = lib.mkIf config.layers.layer-60.gui.desktop-packages.enable {
    environment.systemPackages = with pkgs; [
      logitech-udev-rules
      solaar
      firefox
      jerry
      lobster
      swappy
      wf-recorder
      hicolor-icon-theme

      # Accessories/Utilities
      file-roller
      pavucontrol
      nwg-displays
      webull-desktop
    ];
  };
}
