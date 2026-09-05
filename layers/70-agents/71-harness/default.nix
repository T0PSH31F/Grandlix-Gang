{ lib, ... }:
let
  mkDendriticModule = (import ../../80-lib/81-helpers/mkDendriticModule.nix { inherit lib; }).mkDendriticModule;
  mkDendriticTree = (import ../../80-lib/81-helpers/mkDendriticTree.nix { inherit lib; }).mkDendriticTree;
in
{
  imports = mkDendriticTree mkDendriticModule ./.;
}
