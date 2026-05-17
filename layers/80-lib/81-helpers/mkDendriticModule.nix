{ ... }:
/*
  Wrapper for dendritic multi-class modules.
  Handles both multi-class (nixos/home/options) and standard modules.
*/
let
  mkDendriticModule = name: module: { config, lib, pkgs, ... }@args:
    let
      # If module is a path, import it first
      raw = if builtins.isPath module then import module else module;
      
      # Evaluate the raw module with all arguments provided by Nix, plus osConfig
      evaluated = if builtins.isFunction raw then raw (args // { osConfig = config; }) else raw;
      
      # Detect if it's a multi-class module
      isMultiClass = builtins.hasAttr "nixos" evaluated || builtins.hasAttr "home" evaluated;
      
      opts = evaluated.options or { };
      nixosConf = evaluated.nixos or (if isMultiClass then { } else evaluated.config or (removeAttrs evaluated [ "options" "imports" ]));
      homeConf = if isMultiClass then (evaluated.home or { }) else { };
      imports = evaluated.imports or [ ];
      
      # Detection logic for NixOS vs Home Manager
      isNixOS = builtins.hasAttr "modulesPath" args;

      # Safely evaluate functions only when the context matches
      wrappedNixosConf =
        if isNixOS && builtins.isFunction nixosConf then nixosConf (args // { osConfig = config; })
        else nixosConf;

      wrappedHomeConf =
        if (!isNixOS) && builtins.isFunction homeConf then homeConf (args // { osConfig = config; })
        else homeConf;

      # Predicate for non-empty config (purely structural, never forces content evaluation)
      hasHomeConfig = builtins.hasAttr "home" evaluated;

    in {
      imports = imports;
      options = opts;
      config =
        if isNixOS then
          lib.mkMerge [
            wrappedNixosConf
            (lib.mkIf hasHomeConfig {
              home-manager.users.${config.layers.meta.primaryUser or "t0psh31f"} = wrappedHomeConf;
            })
          ]
        else
          wrappedHomeConf;
    };
in
{
  inherit mkDendriticModule;
}
