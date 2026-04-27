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
  options.features.gui.desktop-packages = {
    enable = lib.mkEnableOption "Common desktop packages" // {
      default = builtins.elem "desktop" clanTags || builtins.elem "workstation" clanTags;
    };
  };

  nixos = lib.mkIf config.features.gui.desktop-packages.enable {
    environment.systemPackages = with pkgs; [
      logitech-udev-rules
      solaar
      firefox
      jerry
      lobster
      swappy
      wf-recorder
      candy-icons
      hicolor-icon-theme
    ];
  };
}
