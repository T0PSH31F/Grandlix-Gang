{ lib, mkDendriticModule, ... }:
{
  imports = [
    (mkDendriticModule "hyprland" ./41-hyprland/default.nix)
    # (mkDendriticModule "niri" ./42-niri/default.nix)
    (mkDendriticModule "noctalia" ./43-noctalia/default.nix)
    (mkDendriticModule "frameworks" ./44-de-frameworks/default.nix)
    (mkDendriticModule "file-managers" ./45-file-managers/default.nix)
    (mkDendriticModule "terminals" ./46-terminal-emulators/default.nix)
    (mkDendriticModule "display" ./47-display/default.nix)
    (mkDendriticModule "rofi" ./48-rofi/default.nix)
  ];
}
