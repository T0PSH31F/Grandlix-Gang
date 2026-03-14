{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.features.home.gui.desktop.media.audio;
in
{
  options.features.home.gui.desktop.media.audio = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true; # Enabled by default since it's imported by the desktop bundle
      description = "Audio visualization and management (cava, cavalier, mpd)";
    };
  };

  config = lib.mkIf cfg.enable {
    # MPD Service and Client
    services.mpd = {
      enable = true;
      musicDirectory = "${config.home.homeDirectory}/Music";
      dataDir = "${config.home.homeDirectory}/.local/share/mpd";
      extraConfig = ''
        audio_output {
          type "pipewire"
          name "PipeWire Output"
        }
      '';
    };

    # Visualization
    programs.cava = {
      enable = true;
      settings = {
        general.framerate = 60;
        input.method = "pipewire";
        smoothing.monstercat = 1;
        color = {
          gradient = 1;
          gradient_count = 8;
          gradient_color_1 = "'#94e2d5'";
          gradient_color_2 = "'#89dceb'";
          gradient_color_3 = "'#74c7ec'";
          gradient_color_4 = "'#89b4fa'";
          gradient_color_5 = "'#cba6f7'";
          gradient_color_6 = "'#f5c2e7'";
          gradient_color_7 = "'#eba0ac'";
          gradient_color_8 = "'#f38ba8'";
        };
      };
    };

    home.packages = with pkgs; [
      cavalier # GUI Visualizer
      mpc # CLI control for mpd
    ];
  };
}
