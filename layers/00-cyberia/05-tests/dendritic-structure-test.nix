# Dendritic Structure & Tag Profile Verification Test
{ pkgs, lib }:
let
  tagRegistry = import ../../90-profiles/tags/default.nix;
  validTags = tagRegistry.validTags;

  tagFiles = builtins.attrNames (
    lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".nix" name) (
      builtins.readDir ../../90-profiles/tags
    )
  );

  expectedTagFiles = map (t: "${t}.nix") validTags ++ [ "default.nix" ];
  missingFromRegistry = lib.filter (f: !(lib.elem f expectedTagFiles)) tagFiles;
in
if missingFromRegistry != [ ] then
  throw "Tag files exist without being in validTags registry: ${lib.concatStringsSep ", " missingFromRegistry}"
else
  pkgs.runCommand "check-dendritic-structure" { } ''
    echo "Dendritic structure & tag registry verified successfully." > $out
  ''
