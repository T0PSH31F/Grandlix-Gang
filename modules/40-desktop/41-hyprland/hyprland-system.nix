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
      withUWSM = true;
      xwayland.enable = true;
    };

    programs.uwsm = {
      enable = true;
      waylandCompositors = {
        hyprland = {
          prettyName = "Hyprland";
          comment = "Hyprland compositor managed by UWSM";
          binPath = "/run/current-system/sw/bin/Hyprland";
        };
      };
    };

    # Re-enable portal configuration from portals.nix
    xdg.portal = {
      enable = true;
      extraPortals = [ ];
      # config.common.default = "*";
    };
  };
}
