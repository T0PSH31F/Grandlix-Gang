{ lib, ... }:
let
  inherit (import ../../layers/80-lib/81-helpers/mkDendriticModule.nix { inherit lib; }) mkDendriticModule;
in
{
  imports = [
    (mkDendriticModule "hyprland" ./41-hyprland/default.nix)
    (mkDendriticModule "niri" ./42-niri/default.nix)
    (mkDendriticModule "noctalia" ./43-noctalia/default.nix)
    (mkDendriticModule "frameworks" ./44-de-frameworks/default.nix)
    (mkDendriticModule "file-managers" ./45-file-managers/default.nix)
    (mkDendriticModule "terminals" ./46-terminal-emulators/default.nix)
    (mkDendriticModule "display" ./47-display/default.nix)
    (mkDendriticModule "utilities" ./48-utilities/default.nix)
  ];
}
