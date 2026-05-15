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
      # Use builtins to avoid forcing evaluation of lazy attributes like 'options'
      isNixOS = builtins.hasAttr "modulesPath" args;
      isHomeManager = !isNixOS;

      # Ensure config blocks are not null
      safeNixosConf = if nixosConf == null then { } else nixosConf;
      safeHomeConf = if homeConf == null then { } else homeConf;

      # Predicate for non-empty config (handles functions too)
      hasHomeConfig = safeHomeConf != { } && safeHomeConf != null;

    in {
      imports = imports
        ++ lib.optional isNixOS safeNixosConf
        ++ lib.optional isHomeManager safeHomeConf
        ++ lib.optional (isNixOS && hasHomeConfig) {
          home-manager.users.t0psh31f = safeHomeConf;
        };
      options = opts;
      config = {
        _module.args.osConfig = lib.mkDefault config;
      };
    };
in
{
  inherit mkDendriticModule;
}
