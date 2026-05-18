{ lib, ... }:
let
  inherit (import ../../../layers/80-lib/81-helpers/mkDendriticModule.nix { inherit lib; }) mkDendriticModule;
in
{
  imports = [
    (mkDendriticModule "brave" ./brave.nix)
    (mkDendriticModule "librewolf" ./librewolf.nix)
    (mkDendriticModule "firefox" ./firefox.nix)
  ];
}
