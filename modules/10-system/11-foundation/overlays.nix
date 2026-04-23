# modules/nixos/overlays.nix
# Purpose:
# - Attach overlays for custom/local packages.
# - Desktop overlay will eventually be conditional on tags; for now
#   we can condition on system-profile.role or hostname as a stepping stone.

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  hasTag = tag: builtins.elem tag (config.machine.tags or [ ]);

  # Theme overlays adapter
  themeOverlays = import ../../80-lib/82-overlays/default.nix { inherit inputs; };
  themeOverlay = final: prev: { };

  # Load overlays from the modular structure
  customOverlay = import ../../80-lib/82-overlays/custom-packages.nix;
  desktopOverlay = import ../../80-lib/82-overlays/desktop-packages.nix;
in
{
  # Custom package fixes always applied
  nixpkgs.overlays = [
    customOverlay
  ]
  ++ lib.optionals (hasTag "desktop") [
    themeOverlay
    desktopOverlay
  ];
}
