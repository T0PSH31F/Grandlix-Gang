{ lib, ... }:
{
  /*
    Resolves tags from clan-core machine definitions into profile imports.
    If a machine has tags = [ "desktop" "workstation" ], this returns
    [ ../../../90-profiles/tags/desktop.nix ../../../90-profiles/tags/workstation.nix ]
  */
  mkMachineFromTags = tags:
    let
      resolveTag = tag: 
        let path = ../../../90-profiles/tags/${tag}.nix;
        in if builtins.pathExists path then path 
           else builtins.trace "WARNING: Tag profile not found: ${tag}" null;
    in
    builtins.filter (x: x != null) (map resolveTag tags);
}
