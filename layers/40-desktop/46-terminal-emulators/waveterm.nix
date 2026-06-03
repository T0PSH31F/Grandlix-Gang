# flake-parts/features/home/gui/desktop/terminal-emulators/waveterm.nix
#
# WaveTerm — AI-native terminal with Matugen/Noctalia dynamic theming.
# The matugen template in cli/theming/templates/waveterm-theme.json
# generates colors from the current wallpaper automatically.
{
  config,
  lib,
  ...
}:

let
  cfg = config.programs.cli-environment;
in
{
  config = lib.mkIf cfg.enable {
    programs.waveterm = {
      enable = true;
      settings = {
        "term:fontfamily" = "JetBrains Mono Nerd Font";
        "term:fontsize" = 14;
        "window:transparent" = true;
        "window:opacity" = 0.92;
        "window:blur" = true;
        "window:tilegap" = 4;
        "window:showmenubar" = false;
        "telemetry:enabled" = false;
      };
      themes.matugen-dynamic = {
        "display:name" = "Matugen Dynamic";
        "display:order" = 1;
      };
    };
  };
}
