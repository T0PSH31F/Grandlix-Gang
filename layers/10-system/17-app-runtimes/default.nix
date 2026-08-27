{ mkDendriticModule, ... }:
{
  imports = [
    (mkDendriticModule "appimage" ./appimage.nix)
    (mkDendriticModule "flatpak" ./flatpak.nix)
  ];
}
