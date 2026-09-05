# WaveTerm — AI-native terminal with Matugen/Noctalia dynamic theming.
{
  config,
  lib,
  pkgs,
  osConfig ? config,
  ...
}:
let
  clanTags = osConfig.machine.tags or [ ];
  hasDesktopTag = builtins.elem "desktop" clanTags;
in
{
  config = lib.mkIf hasDesktopTag {
    home.packages = [ pkgs.waveterm ];

    xdg.configFile."waveterm/settings.json".text = builtins.toJSON {
      "term:fontfamily" = "JetBrains Mono Nerd Font";
      "term:fontsize" = 14;
      "window:transparent" = true;
      "window:opacity" = 0.92;
      "window:blur" = true;
      "window:tilegap" = 4;
      "window:showmenubar" = false;
      "telemetry:enabled" = false;
    };
  };
}
