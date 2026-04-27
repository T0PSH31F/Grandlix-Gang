{ lib, ... }:
let
  inherit (import ../../../layers/80-lib/81-helpers/mkDendriticModule.nix { inherit lib; }) mkDendriticModule;
in
{
  imports = [
    (mkDendriticModule "audio" ./audio.nix)
    (mkDendriticModule "mpv" ./mpv.nix)
    (mkDendriticModule "packages-media" ./packages-media.nix)
    (mkDendriticModule "spicetify" ./spicetify.nix)
    (mkDendriticModule "vlc" ./vlc.nix)
  ];
}
