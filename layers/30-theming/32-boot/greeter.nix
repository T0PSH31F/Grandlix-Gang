{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.layers.layer-30.theming.themes.greeter;

  # SDDM Sugar Dark with custom video background
  sddm-theme-custom = pkgs.stdenv.mkDerivation {
    name = "sddm-theme-sugar-dark-custom";
    src = pkgs.sddm-sugar-dark;
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/share/sddm/themes/sugar-dark
      cp -R $src/share/sddm/themes/sugar-dark/. $out/share/sddm/themes/sugar-dark/
      chmod -R u+w $out/share/sddm/themes/sugar-dark/
      
      # Overwrite the background with your mp4
      cp "${cfg.sddm.background}" $out/share/sddm/themes/sugar-dark/Background.jpg

      # Patch theme.conf to use Background.jpg and ensure it's visible
      sed -i 's/Background=.*/Background="Background.jpg"/' $out/share/sddm/themes/sugar-dark/theme.conf
    '';
  };
in
{
  options.layers.layer-30.theming.themes.greeter = {
    sddm = {
      enable = mkEnableOption "SDDM with Sugar Candy theme";
      background = mkOption {
        type = types.path;
        default = ../../00-cyberia/02-assets/sddm_background/fallback1.jpg;
        description = "Path to the background video/image for SDDM";
      };
    };
    greetd = {
      enable = mkEnableOption "Greetd with tuigreet/ReGreet";
      background = mkOption {
        type = types.path;
        default = ../../00-cyberia/02-assets/sddm_background/fallback1.jpg;
      };
    };
  };

  config = mkMerge [
    # SDDM Implementation
    (mkIf cfg.sddm.enable {
      services.greetd.enable = lib.mkForce false;
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true; # Run SDDM itself on Wayland
        theme = "sugar-dark";
        settings = {
          General = {
            InputMethod = ""; # Disable virtual keyboard if not needed
          };
        };
      };

      environment.systemPackages = [
        sddm-theme-custom
      ];
    })

    # Greetd Implementation (Fallback/Legacy)
    (mkIf cfg.greetd.enable {
      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd 'uwsm start hyprland'";
            user = "greeter";
          };
        };
      };
    })
  ];
}
