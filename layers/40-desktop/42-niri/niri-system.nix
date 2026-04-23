# flake-parts/features/nixos/desktop/niri-system.nix
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
  # Ensure the niri NixOS module from inputs is available if needed,
  # or just rely on nixpkgs's program.niri if it's there.
  # The flake already defines 'niri' in inputs.

  imports = [ inputs.niri.nixosModules.niri ];

  config = lib.mkIf (hasTag "desktop") {
    programs.niri.enable = true;
    programs.niri.package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-stable;

    # We also register it in programs.uwsm.waylandCompositors for standard UWSM support,
    # though we've also added a manual desktop entry in Home Manager for your specific format.
    programs.uwsm.waylandCompositors.niri = {
      prettyName = "Niri";
      comment = "Niri compositor managed by UWSM";
      binPath = "/run/current-system/sw/bin/niri";
    };
  };
}
