{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.layers.layer-30.theming.themes.greeter;
in
{
  options.layers.layer-30.theming.themes.greeter = {
    sddm = {
      enable = mkEnableOption "SDDM with Astronaut theme";
    };
    greetd = {
      enable = mkEnableOption "Greetd with ReGreet (cage)";
      background = mkOption {
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
        wayland.enable = true;
        theme = "sddm-astronaut-theme";
      };

      environment.systemPackages = [
        (pkgs.sddm-astronaut.override {
          themeConfig = {
            Background = "../../00-cyberia/02-assets/sddm_background/fallback1.jpg";
          };
        })
      ];
    })

    # Greetd Implementation (cage + regreet per best practice)
    (mkIf cfg.greetd.enable {
      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            # Minimal, stable Wayland greeter host (cage kiosk)
            command = "${pkgs.cage}/bin/cage -s -- ${pkgs.regreet}/bin/regreet";
            user = "greeter";
          };
        };
      };

      programs.regreet = {
        enable = true;
        settings = {
          background = {
            path = builtins.toString cfg.greetd.background;
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

