{ lib, ... }:
let
  inherit (import ../../layers/80-lib/81-helpers/mkDendriticModule.nix { inherit lib; })
    mkDendriticModule
    ;
in
{
  imports = [
    (mkDendriticModule "hermes" ./hermes.nix)
    (mkDendriticModule "hermes-workspace" ./workspace.nix)
    (mkDendriticModule "hermes-dashboard" ./dashboard.nix)
  ];
}
