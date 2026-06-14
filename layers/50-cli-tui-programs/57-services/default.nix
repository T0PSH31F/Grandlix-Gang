{ lib, ... }:
let
  inherit (import ../../../layers/80-lib/81-helpers/mkDendriticModule.nix { inherit lib; })
    mkDendriticModule
    ;
in
{
  imports = [
    (mkDendriticModule "local-ai" ./local-ai.nix)
    (mkDendriticModule "podman" ./podman.nix)
    (mkDendriticModule "rclone" ./rclone.nix)
  ];
}
