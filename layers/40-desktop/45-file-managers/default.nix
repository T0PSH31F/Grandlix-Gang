{ lib, mkDendriticModule, ... }:
{
  imports = [
    (mkDendriticModule "dolphin" ./dolphin.nix)
    (mkDendriticModule "file-managers-system" ./file-managers-system.nix)
    (mkDendriticModule "nemo" ./nemo.nix)
  ];
}
