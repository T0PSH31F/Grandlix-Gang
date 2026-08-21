{ lib, mkDendriticModule, ... }:
{
  imports = [
    (mkDendriticModule "local-ai" ./local-ai.nix)
    (mkDendriticModule "podman" ./podman.nix)
    (mkDendriticModule "rclone" ./rclone.nix)
  ];
}
