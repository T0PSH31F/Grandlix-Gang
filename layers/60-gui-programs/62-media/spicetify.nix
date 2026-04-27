{
  pkgs,
  lib,
  config,
  inputs,
  osConfig ? config,
  ...
}:
let
  clanTags = osConfig.machine.tags or [ ];
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  options.features.gui.spicetify = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = builtins.elem "desktop" clanTags;
      description = "Enable Spicetify";
    };
  };

  home = { config, osConfig, ... }: {
    imports = lib.optionals osConfig.features.gui.spicetify.enable [
      inputs.spicetify-nix.homeManagerModules.default
    ];

    config = lib.mkIf osConfig.features.gui.spicetify.enable {
      programs.spicetify = {
        enable = true;
        theme = spicePkgs.themes.comfy;

        enabledExtensions = with spicePkgs.extensions; [
          adblock
          beautifulLyrics
          betterGenres
          fullAlbumDate
          fullAppDisplay
          hidePodcasts
          historyShortcut
          popupLyrics
          shuffle
          skipStats
          songStats
          volumePercentage
          wikify
        ];
      };
    };
  };
}
