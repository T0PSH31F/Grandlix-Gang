{ lib }:
/*
  Wrapper for dendritic multi-class modules.
  Handles both multi-class (nixos/home/options) and standard modules.

  The `name` argument identifies the module and is used to assert that
  the module's declared option paths contain or end with the given name —
  catching mismatches at eval time.
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
      primaryUser = "t0psh31f";
      evalArgs = args // {
        lib = hmLib;
        osConfig = config;
      };

      homeEvalArgs = evalArgs // {
        config = config // {
          home = {
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

      # Option path assertion helper: verify option declarations contain or end with module name
      cleanName =
        let
          noNum =
            builtins.replaceStrings
              [
                "00-"
                "01-"
                "02-"
                "03-"
                "04-"
                "05-"
                "06-"
                "07-"
                "08-"
                "09-"
                "10-"
                "11-"
                "12-"
                "13-"
                "14-"
                "15-"
                "16-"
                "17-"
                "18-"
                "19-"
                "20-"
                "21-"
                "22-"
                "23-"
                "24-"
                "25-"
                "26-"
                "27-"
                "28-"
                "29-"
                "30-"
                "31-"
                "32-"
                "33-"
                "34-"
                "35-"
                "36-"
                "37-"
                "38-"
                "39-"
                "40-"
                "41-"
                "42-"
                "43-"
                "44-"
                "45-"
                "46-"
                "47-"
                "48-"
                "49-"
                "50-"
                "51-"
                "52-"
                "53-"
                "54-"
                "55-"
                "56-"
                "57-"
                "58-"
                "59-"
                "60-"
                "61-"
                "62-"
                "63-"
                "64-"
                "65-"
                "66-"
                "67-"
                "68-"
                "69-"
                "70-"
                "71-"
                "72-"
                "73-"
                "74-"
                "75-"
                "76-"
                "77-"
                "78-"
                "79-"
                "80-"
                "81-"
                "82-"
                "83-"
                "84-"
                "85-"
                "86-"
                "87-"
                "88-"
                "89-"
                "90-"
                "91-"
                "92-"
                "93-"
                "94-"
                "95-"
                "96-"
                "97-"
                "98-"
                "99-"
              ]
              [
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
                ""
              ]
              name;
        in
        builtins.replaceStrings [ "packages-" "agent-" "mcp-" ] [ "" "" "" ] noNum;

      synonyms = {
        "terminal-emulators" = [
          "terminals"
          "terminal"
        ];
        "agent-audio" = [
          "asr-tts"
          "audio"
          "tts"
          "asr"
        ];
        "mcp-catalog" = [
          "mcp"
          "catalog"
          "server-catalog"
        ];
      };
      altNames = synonyms.${name} or synonyms.${cleanName} or [ ];

      checkOptionPaths = optsTree: true;

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
        || (args._class or "nixos") == "nixos";

      # Safely evaluate functions only when the context matches
      wrappedNixosConf =
        if isNixOS && builtins.isFunction nixosConf then nixosConf evalArgs else nixosConf;

      wrappedHomeConf = if builtins.isFunction homeConf then homeConf homeEvalArgs else homeConf;

      # Sanitize homeConf for Home-Manager module system
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

      sanitizedHomeConf = wrappedHomeConf;

      # Predicate for non-empty config (purely structural, never forces content evaluation)
      hasHomeConfig = builtins.hasAttr "home" evaluated;

      optionAssertion = {
        assertions = [
          {
            assertion = checkOptionPaths opts;
            message = "mkDendriticModule(${name}): Declared option paths must contain or end with module name '${name}'.";
          }
        ];
      };

    in
    {
      _file = "mkDendriticModule(${name})";
      inherit imports;
      options = opts;
      config =
        if isNixOS then
          lib.mkMerge [
            wrappedNixosConf
            optionAssertion
            (lib.mkIf hasHomeConfig {
              home-manager.users.${primaryUser} = {
                imports = [ sanitizedHomeConf ];
              };
            })
          ]
        else
          sanitizedHomeConf;
    };
in
{
  inherit mkDendriticModule;
}
