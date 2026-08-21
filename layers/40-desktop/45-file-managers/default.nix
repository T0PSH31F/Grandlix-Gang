{ lib, mkDendriticModule, ... }:
{
  imports = [
    (mkDendriticModule "dolphin" ./dolphin.nix)
    ./file-managers-system.nix
    (mkDendriticModule "nemo" ./nemo.nix)
  ];
}
