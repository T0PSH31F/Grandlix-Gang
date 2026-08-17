{ lib, ... }:
let
  inherit (import ../../../layers/80-lib/81-helpers/mkDendriticModule.nix { inherit lib; })
    mkDendriticModule
    ;
in
{
  imports = [
    (mkDendriticModule "hermes" ./hermes.nix)
    (mkDendriticModule "hermes-workspace" ./workspace.nix)
    (mkDendriticModule "hermes-dashboard" ./dashboard.nix)
    (mkDendriticModule "hermes-live-voice" ./hermes-live-voice.nix)
    (mkDendriticModule "hermes-evaluator" ./hermes-evaluator.nix)
  ];
}
