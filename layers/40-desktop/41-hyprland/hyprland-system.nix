# flake-parts/desktop/hyprland.nix
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  hasTag = tag: builtins.elem tag (config.machine.tags or [ ]);
in
{
  imports = [ inputs.hyprland.nixosModules.default ];

  config = lib.mkIf (hasTag "desktop") {
    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage =
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      withUWSM = false;
      xwayland.enable = true;
    };

    programs.uwsm = {
      enable = false;
    };

    # Re-enable portal configuration from portals.nix
    xdg.portal = {
      enable = true;
      extraPortals = [ ];
      # config.common.default = "*";
    };
  };
}
