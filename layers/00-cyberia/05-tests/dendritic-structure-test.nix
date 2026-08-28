# Dendritic Structure, Guardrails, & Tag Profile Verification Test
{ pkgs, lib }:
let
  validTags = [
    "ai-agent"
    "ai-server"
    "cache-server"
    "desktop"
    "development"
    "gaming"
    "gpu-compute"
    "homelab"
    "intel-12th-gen"
    "intel-9th-gen"
    "laptop"
    "media"
    "server"
    "workstation"
  ];

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
  pkgs.runCommand "check-dendritic-structure"
    {
      nativeBuildInputs = [ pkgs.gnugrep ];
    }
    ''
      set -e

      # 1. Zero relative helper imports in layers/
      if grep -rn "import \.\./" ${../../.}/layers/ >/dev/null 2>&1; then
        echo "ERROR: Relative helper imports found in layers/"
        exit 1
      fi

      # 2. Zero mkForce under layers/90-profiles/
      if grep -rn "mkForce" ${../../.}/layers/90-profiles/ >/dev/null 2>&1; then
        echo "ERROR: lib.mkForce found under layers/90-profiles/"
        exit 1
      fi

      # 3. Hyprland base contains zero "noctalia" strings
      if grep -ri "noctalia" ${../../.}/layers/40-desktop/41-hyprland/ >/dev/null 2>&1; then
        echo "ERROR: noctalia reference found in neutral Hyprland base (layers/40-desktop/41-hyprland/)"
        exit 1
      fi

      # 4. Zero commented-out imports in default.nix files
      if grep -rn "#.*imports =" ${../../.}/layers/ --include=default.nix >/dev/null 2>&1; then
        echo "ERROR: Commented-out imports found in default.nix files"
        exit 1
      fi

      echo "Dendritic structure & guardrail checks passed successfully." > $out
    ''
