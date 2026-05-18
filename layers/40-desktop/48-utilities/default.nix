{ lib, ... }:
let
  inherit (import ../../../layers/80-lib/81-helpers/mkDendriticModule.nix { inherit lib; }) mkDendriticModule;
in
{
  imports = [
    (mkDendriticModule "social" ./social.nix)
    (mkDendriticModule "udiskie" ./udiskie.nix)
  ];
}
