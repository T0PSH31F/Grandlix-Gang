# flake-parts/features/home/gui/desktop/udiskie.nix
{
  lib,
  osConfig,
  ...
}:
let
  inherit (lib) mkIf;
  # Use osConfig if available (when used as NixOS module), fallback to false
  nixosAutomountEnabled = osConfig.hardware-config.automount.enable or false;
  nixosUseUdiskie = osConfig.hardware-config.automount.useUdiskie or true;
in
{
  config = mkIf (nixosAutomountEnabled && nixosUseUdiskie) {
    services.udiskie = {
      enable = true;
      tray = "auto"; # or "always"
      notify = true;
    };
  };
}
