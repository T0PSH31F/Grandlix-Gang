{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.layers.layer-30.theming.themes.greeter;

  # Greetd / Hyprland config
  greetdHyprConfig = pkgs.writeText "greetd-hyprland.conf" ''
    # Start mpv to play the background video
    exec-once = ${pkgs.mpv}/bin/mpv --loop --no-audio --vo=gpu "${cfg.greetd.background}"
    # Start the actual greeter (ReGreet is a good GTK4 choice)
    exec-once = sh -c "${pkgs.regreet}/bin/regreet; hyprctl dispatch exit"

    monitor=,highrr,auto,1
    # Minimal styling to stay out of the way
    misc {
      disable_hyprland_logo = true
      disable_splash_rendering = true
    }

    ${optionalString (config.hardware.nvidia.enable or false) ''
      cursor {
        no_hardware_cursors = true
      }
    ''}
  '';
in
{
  options.layers.layer-30.theming.themes.greeter = {
    sddm = {
      enable = mkEnableOption "SDDM with Sugar Dark theme";
    };
    greetd = {
      enable = mkEnableOption "Greetd with ReGreet and Hyprland";
      background = mkOption {
        type = types.path;
        default = ../../00-cyberia/02-assets/sddm_background/one-piece-skull.1920x1080.mp4;
        description = "Path to the background video for Greetd/Hyprland";
      };
      greetd-background = mkOption {
        type = types.path;
        default = ../../00-cyberia/02-assets/sddm_background/fallback1.jpg;
        description = "Path to the background image for ReGreet";
      };
    };
  };

  config = mkMerge [
    {
      assertions = [
        {
          assertion = !(cfg.sddm.enable && cfg.greetd.enable);
          message = "SDDM and Greetd cannot be enabled at the same time in the greeter configuration.";
        }
      ];
    }

    # SDDM Implementation
    (mkIf cfg.sddm.enable {
      services.xserver.enable = true;
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = false;
        theme = "sugar-dark";
      };

      environment.systemPackages = [
        pkgs.sddm-sugar-dark
      ];
    })

    # Greetd Implementation
    (mkIf cfg.greetd.enable {
      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.hyprland}/bin/Hyprland --config ${greetdHyprConfig}";
            user = "greeter";
          };
        };
      };

      programs.regreet = {
        enable = true;
        settings = {
          background = {
            path = builtins.toString cfg.greetd.greetd-background;
            fit = "Cover";
          };
          GTK = lib.mkDefault {
            icon_theme_name = "candy-icons";
            theme_name = "adw-gtk3-dark";
          };
        };
      };
    })
  ];
}
