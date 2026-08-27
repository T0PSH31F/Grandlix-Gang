{ mkDendriticModule, ... }:
{
  imports = [
    (mkDendriticModule "impermanence" ./impermanence.nix)
    (mkDendriticModule "google-drive" ./google-drive.nix)
  ];
}
