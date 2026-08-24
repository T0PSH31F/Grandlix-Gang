{ mkDendriticModule, ... }:
{
  imports = [
    ./music-production.nix
    ./image-editing.nix
    ./office.nix
    ./recording.nix
    ./3d-modeling.nix
    ./pentesting
    (mkDendriticModule "wl_shimeji" ./wl_shimeji.nix)
  ];
}
