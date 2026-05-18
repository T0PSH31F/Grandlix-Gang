{ lib, ... }:
let
  inherit (import ../../layers/80-lib/81-helpers/mkDendriticModule.nix { inherit lib; }) mkDendriticModule;
in
{
  imports = [
    (mkDendriticModule "cursor" ./31-cursor/default.nix)
    ./32-boot
    (mkDendriticModule "gtk" ./33-gtk/default.nix)
    (mkDendriticModule "qt" ./34-qt/default.nix)
    (mkDendriticModule "stylix" ./35-stylix/default.nix)
    (mkDendriticModule "sfx" ./36-sfx/default.nix)
  ];
}
