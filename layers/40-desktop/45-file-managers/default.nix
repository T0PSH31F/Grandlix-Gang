{ lib, ... }@args:
let
  inherit (import ../../../layers/80-lib/81-helpers/mkDendriticModule.nix { inherit lib; }) mkDendriticModule;
in
{
  imports = [
    (mkDendriticModule "dolphin" ./dolphin.nix)
    ./file-managers-system.nix
    (mkDendriticModule "nemo" ./nemo.nix)
  ];
}
