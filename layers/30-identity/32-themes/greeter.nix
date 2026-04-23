{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.themes.greeter;

  # SDDM Sugar Candy Custom with video background
  sddm-theme-sugar-candy = pkgs.stdenv.mkDerivation {
    name = "sddm-theme-sugar-candy";
    src = pkgs.fetchFromGitHub {
      owner = "MarianArlt";
      repo = "sddm-sugar-candy";
      rev = "v1.5";
      sha256 = "sha256-m99it7SRAOpgvMctofvSsh99fF9m/y/idS+Fk5Jp6w8=";
    };
    installPhase = ''
      mkdir -p $out/share/sddm/themes/sugar-candy
      cp -R . $out/share/sddm/themes/sugar-candy
      # Overwrite the background with your mp4/gif
      cp "${cfg.sddm.background}" $out/share/sddm/themes/sugar-candy/Background.mp4

      # Patch theme.conf to use Background.mp4
      sed -i 's/Background=.*/Background="Background.mp4"/' $out/share/sddm/themes/sugar-candy/theme.conf
    '';
  };

  # Greetd / Hyprland config
  greetdHyprConfig = pkgs.writeText "greetd-hyprland.conf" ''
    # Start mpv to play the background video
    exec-once = ${pkgs.mpv}/bin/mpv --loop --no-audio --vo=wayland "${cfg.greetd.background}"
    # Start the actual greeter (ReGreet is a good GTK4 choice)
    exec-once = ${pkgs.regreet}/bin/regreet; hyprctl dispatch exit

    monitor=,highrr,auto,1
    # Minimal styling to stay out of the way
    misc {
      disable_hyprland_logo = true
      disable_splash_rendering = true
    }
  '';
in
{
  options.themes.greeter = {
    sddm = {
      enable = mkEnableOption "SDDM with Sugar Candy theme";
      background = mkOption {
        type = types.path;
        default = ../../../../layers/00-cyberia/02-assets/sddm_background/one-piece-skull.1920x1080.mp4;
        description = "Path to the background video/image for SDDM";
      };
    };
    greetd = {
      enable = mkEnableOption "Greetd with ReGreet and Hyprland";
      background = mkOption {
        type = types.path;
        default = ../../../../layers/00-cyberia/02-assets/sddm_background/one-piece-skull.1920x1080.mp4;
        description = "Path to the background video for Greetd/Hyprland";
      };
      greetd-background = mkOption {
        type = types.path;
        default = ../../../../layers/00-cyberia/02-assets/sddm_background/fallback1.jpg;
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
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        theme = "sugar-candy";
      };

      environment.systemPackages = [
        sddm-theme-sugar-candy
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
