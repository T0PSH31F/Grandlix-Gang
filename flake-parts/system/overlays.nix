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
  themeOverlays = import ../../overlays/default.nix { inherit inputs; };
  themeOverlay = final: prev: { };

  # Custom package fixes (noto-fonts-subset, etc.)
  customOverlay = import ../../overlays/custom-packages.nix;

  # Desktop overlay
  desktopOverlay = import ../../overlays/desktop-packages.nix;
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
