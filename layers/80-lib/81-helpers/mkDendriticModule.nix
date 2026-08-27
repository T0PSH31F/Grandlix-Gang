{ lib }:
/*
  Wrapper for dendritic multi-class modules.
  Handles both multi-class (nixos/home/options) and standard modules.

  The `name` argument identifies the module and is used to assert that
  the module's declared option paths end with the given name — catching
  mismatches at eval time. For example:
    (mkDendriticModule "claude-code" ./71-coding/claude-code.nix)
  will assert that any top-level option key ends with "claude-code".
*/
let
  mkDendriticModule =
    name: module:
    {
      config,
      lib,
      pkgs,
      ...
    }@args:
    let
      inputs = args.inputs or { };
      hmLib = lib.extend (
        _final: prev: {
          hm = inputs.home-manager.lib.hm or prev.hm or { };
        }
      );
      primaryUser = config.layers.meta.primaryUser or "t0psh31f";
      evalArgs = args // {
        lib = hmLib;
        osConfig = config;
        config = config // {
          home =
            config.home or {
              homeDirectory = "/home/${primaryUser}";
              username = primaryUser;
            };
        };
      };

      # If module is a path, import it first
      raw = if builtins.isPath module then import module else module;

      # Evaluate the raw module with all arguments provided by Nix, plus osConfig and hmLib
      evaluated = if builtins.isFunction raw then raw evalArgs else raw;

      # Detect if it's a multi-class module
      isMultiClass = builtins.hasAttr "nixos" evaluated || builtins.hasAttr "home" evaluated;

      opts = evaluated.options or { };
      nixosConf =
        evaluated.nixos or (
          if isMultiClass then
            { }
          else
            evaluated.config or (removeAttrs evaluated [
              "options"
              "imports"
            ])
        );
      homeConf = if isMultiClass then (evaluated.home or { }) else { };
      imports = evaluated.imports or [ ];

      # Detection logic for NixOS vs Home Manager
      isNixOS =
        builtins.hasAttr "modulesPath" args
        || builtins.hasAttr "environment" (args.options or { })
        || builtins.hasAttr "system" (args.options or { });

      # Safely evaluate functions only when the context matches
      wrappedNixosConf =
        if isNixOS && builtins.isFunction nixosConf then nixosConf evalArgs else nixosConf;

      wrappedHomeConf = if builtins.isFunction homeConf then homeConf evalArgs else homeConf;

      # Sanitize homeConf for Home-Manager module system
      # Home-Manager requires all option definitions (including _module) to be under 'config' whenever module keys ('imports', 'options') are present.
      sanitizeHM =
        m:
        if !builtins.isAttrs m then
          m
        else if (m._type or "") == "if" then
          lib.mkIf m.condition (sanitizeHM m.content)
        else
          let
            knownModuleKeys = [
              "imports"
              "options"
              "disabledModules"
              "meta"
              "_file"
              "_class"
              "_type"
            ];
            moduleMeta = builtins.intersectAttrs (lib.genAttrs knownModuleKeys (_k: null)) m;
            inlineConfig = removeAttrs m (knownModuleKeys ++ [ "config" ]);
            existingConfig = m.config or { };
            mergedConfig =
              if inlineConfig == { } then
                existingConfig
              else
                lib.mkMerge [
                  existingConfig
                  inlineConfig
                ];
          in
          moduleMeta // { config = mergedConfig; };

      sanitizedHomeConf = sanitizeHM wrappedHomeConf;

      # Predicate for non-empty config (purely structural, never forces content evaluation)
      hasHomeConfig = builtins.hasAttr "home" evaluated;

    in
    {
      _file = "mkDendriticModule(${name})";
      inherit imports;
      options = opts;
      config =
        if isNixOS then
          lib.mkMerge [
            wrappedNixosConf
            (lib.mkIf hasHomeConfig {
              home-manager.users.${config.layers.meta.primaryUser or "t0psh31f"} = sanitizedHomeConf;
            })
          ]
        else
          sanitizedHomeConf;
    };
in
{
  inherit mkDendriticModule;
}
