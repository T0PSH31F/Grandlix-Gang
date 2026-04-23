# flake-parts/features/nixos/packages/desktop.nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  hasTag = tag: builtins.elem tag (config.machine.tags or [ ]);
in
{
  config = lib.mkIf (hasTag [ "desktop" ] || hasTag "laptop") {
    environment.systemPackages = with pkgs; [
      logitech-udev-rules
      solaar

      # Browsers
      firefox

      # Custom desktop tools
      jerry
      lobster

      # Wayland / screenshot
      swappy
      wf-recorder

      # Icons
      candy-icons
      hicolor-icon-theme
    ];
  };
}
