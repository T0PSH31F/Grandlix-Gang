/*
  mkDendriticTree — Auto-import directory scanner for dendritic layers.

  Scans a directory and wraps every .nix file (except default.nix) and
  every subdirectory containing a default.nix via mkDendriticModule,
  using the file/directory basename as the module name.

  Conventions:
    - Files/dirs ending with `.disabled` are skipped (opt-out mechanism)
    - Files starting with `_` are skipped (private helpers)
    - `.gitkeep` files are skipped
    - `default.nix` at the scanned level is skipped (it's the caller)
    - `packages-*.nix` files are imported RAW (not wrapped) — they're
      package lists, not dendritic modules

  Usage in a layer default.nix:
    { mkDendriticModule, mkDendriticTree, ... }:
    {
      imports = mkDendriticTree mkDendriticModule ./.;
    }
*/
{ lib }:
let
  mkDendriticTree =
    mkDendriticModule: dir:
    let
      entries = builtins.readDir dir;

      # Filter function: should this entry be processed?
      shouldProcess =
        name: _type:
        let
          isDisabled = lib.hasSuffix ".disabled" name;
          isPrivate = lib.hasPrefix "_" name;
          isGitkeep = name == ".gitkeep";
          isDefault = name == "default.nix";
        in
        !(isDisabled || isPrivate || isGitkeep || isDefault);

      # Determine if a .nix file should be wrapped or imported raw
      isRawImport = name: lib.hasPrefix "packages-" name || lib.hasSuffix "-system.nix" name;

      # Process a single entry
      processEntry =
        name: type:
        let
          path = dir + "/${name}";
        in
        if type == "regular" && lib.hasSuffix ".nix" name then
          let
            moduleName = lib.removeSuffix ".nix" name;
          in
          if isRawImport name then
            # Raw import — not a dendritic module (package lists, system helpers)
            [ path ]
          else
            [ (mkDendriticModule moduleName path) ]
        else if type == "directory" && builtins.pathExists (path + "/default.nix") then
          let
            raw = import (path + "/default.nix");
            isPureAggregator =
              builtins.isFunction raw
              && (
                let
                  fargs = builtins.functionArgs raw;
                in
                (builtins.hasAttr "mkDendriticTree" fargs || builtins.hasAttr "mkDendriticModule" fargs)
                && !(builtins.hasAttr "config" fargs || builtins.hasAttr "pkgs" fargs)
              );
          in
          if isPureAggregator then
            [ path ]
          else
            [ (mkDendriticModule name path) ]
        else
          [ ];

      # Build the import list
      filtered = lib.filterAttrs shouldProcess entries;
      imports = lib.concatLists (lib.mapAttrsToList processEntry filtered);
    in
    imports;
in
{
  inherit mkDendriticTree;
}
