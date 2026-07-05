{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.layers.layer-30.theming.themes.greeter;
in
{
  imports = [
    inputs.noctalia-greeter.nixosModules.default
  ];

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
    noctalia-greeter = {
      enable = mkEnableOption "Noctalia Greeter (native Wayland login)";
      session = mkOption {
        type = types.str;
        default = "hyprland";
        description = "Default session to launch (hyprland, niri, etc.)";
      };
    };
  };

  config = mkMerge [
    {
      assertions = [
        {
          assertion = !(cfg.sddm.enable && cfg.greetd.enable);
          message = "SDDM and Greetd cannot be enabled at the same time.";
        }
        {
          assertion = !(cfg.sddm.enable && cfg.noctalia-greeter.enable);
          message = "SDDM and Noctalia Greeter cannot be enabled at the same time.";
        }
        {
          assertion = !(cfg.greetd.enable && cfg.noctalia-greeter.enable);
          message = "ReGreet and Noctalia Greeter cannot be enabled at the same time.";
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

    # Noctalia Greeter Implementation
    (mkIf cfg.noctalia-greeter.enable {
      users.users.greeter = {
        isSystemUser = true;
        group = "greeter";
      };
      users.groups.greeter = {};

      services.greetd.settings.default_session.user = "greeter";

      programs.noctalia-greeter = {
        enable = true;
        package = inputs.noctalia-greeter.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
          nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.linuxHeaders ];
          buildInputs = (old.buildInputs or []) ++ [ pkgs.linuxHeaders ];
        });
        greeter-args = "--session ${cfg.noctalia-greeter.session}";
        settings = {
          cursor = {
            theme = "Bibata-Modern-Ice";
            size = 24;
            path = "${pkgs.bibata-cursors}/share/icons";
          };
          keyboard = {
            layout = "us";
          };
          appearance = {
            password_style = "random";
          };
        };
      };

      environment.systemPackages = [
        pkgs.bibata-cursors
      ];
    })
  ];
}
