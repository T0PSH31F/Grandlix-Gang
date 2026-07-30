{ lib, ... }:
let
  inherit (import ../../../layers/80-lib/81-helpers/mkDendriticModule.nix { inherit lib; })
    mkDendriticModule
    ;
in
{
  imports = [
    (mkDendriticModule "herm" ./herm.nix)
    (mkDendriticModule "open-skills" ./open-skills.nix)
  ];
}
