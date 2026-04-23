{ lib, ... }:
{
  /*
    Resolves tags from clan-core machine definitions into profile imports.
    If a machine has tags = [ "desktop" "workstation" ], this returns
    [ ../../modules/90-profiles/tags/desktop.nix ../../modules/90-profiles/tags/workstation.nix ]
  */
  mkMachineFromTags = tags:
    let
      resolveTag = tag: ../../../modules/90-profiles/tags/${tag}.nix;
    in
    map resolveTag tags;
}
