{ lib, ... }:
let
  inherit (import ../../../layers/80-lib/81-helpers/mkDendriticModule.nix { inherit lib; }) mkDendriticModule;
in
{
  imports = [
    (mkDendriticModule "packages-pentest" ./packages-pentest.nix)
    (mkDendriticModule "pentest-tools" ./pentest-tools.nix)
  ];
}
