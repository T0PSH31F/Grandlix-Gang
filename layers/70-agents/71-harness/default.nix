{ lib, ... }:
let
  inherit ((import ../../80-lib/81-helpers/mkDendriticModule.nix { inherit lib; })) mkDendriticModule;
  inherit ((import ../../80-lib/81-helpers/mkDendriticTree.nix { inherit lib; })) mkDendriticTree;
in
{
  imports = mkDendriticTree mkDendriticModule ./.;
}
