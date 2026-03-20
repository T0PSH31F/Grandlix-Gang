{
  config,
  lib,
  ...
}:
let
  cfg = config.desktop.noctalia;
in
{
  config = lib.mkIf (cfg.enable && (cfg.backend == "niri" || cfg.backend == "both")) {
    # Niri native output config
    programs.niri.settings.outputs = {
      "HDMI-A-1" = {
        mode = {
          width = 3840;
          height = 2160;
          refresh = 30.0;
        };
        scale = 2.0;
        position = {
          x = 0;
          y = 0;
        };
      };
      "eDP-1" = {
        mode = {
          width = 2560;
          height = 1600;
          refresh = 60.0;
        };
        scale = 1.6;
        position = {
          x = 1920;
          y = 80; # Bottom aligned (1080 - 1000)
        };
      };
      "DP-2" = {
        mode = {
          width = 1920;
          height = 1080;
          refresh = 60.0;
        };
        scale = 1.0;
        position = {
          x = 3520;
          y = 0;
        };
      };
    };
  };
}
