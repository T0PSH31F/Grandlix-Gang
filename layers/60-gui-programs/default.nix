{ lib, ... }:
let
  inherit (import ../../layers/80-lib/81-helpers/mkDendriticModule.nix { inherit lib; }) mkDendriticModule;
in
{
  imports = [
    (mkDendriticModule "browsers" ./61-browsers/default.nix)
    (mkDendriticModule "media" ./62-media/default.nix)
    (mkDendriticModule "documents" ./63-documents/default.nix)
    (mkDendriticModule "development" ./64-development/default.nix)
    (mkDendriticModule "gaming" ./65-gaming/default.nix)
    (mkDendriticModule "security" ./66-security/default.nix)
    (mkDendriticModule "packages-desktop" ./packages-desktop.nix)
    (mkDendriticModule "activities" ./67-activities/default.nix)
  ];
}
