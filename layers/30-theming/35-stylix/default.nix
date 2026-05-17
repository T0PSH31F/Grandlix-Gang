# Stylix base16 styling orchestrator
{
  config,
  lib,
  pkgs,
  osConfig ? config,
  inputs,
  ...
}:
let
  cfg = osConfig.layers.layer-30.theming.stylix;
in
{
  # Only import stylix if it's defined in inputs
  imports = lib.optionals (inputs ? stylix) [
    inputs.stylix.nixosModules.stylix
  ];

  options.layers.layer-30.theming.stylix = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = builtins.elem "desktop" (osConfig.machine.tags or [ ]);
      description = "Enable Stylix base16 system-wide styling orchestrator";
    };
  };

  # 1. Stylix config
  nixos = lib.mkIf (cfg.enable && (inputs ? stylix)) {
    stylix = {
      enable = true;
      image = ../../00-cyberia/02-assets/sddm_background/fallback1.jpg;
      polarity = "dark";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
      homeManagerIntegration.autoImport = true;
      homeManagerIntegration.followSystem = true;

      # Greetd/ReGreet is managed directly by our themes module (allows custom per-machine backgrounds)
      targets.regreet.enable = false;

      # Plymouth and GRUB are managed directly by our dedicated boot theme modules
      targets.plymouth.enable = false;
      targets.grub.enable = false;

      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
      };

      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.fira-code;
          name = "FiraCode Nerd Font";
        };
        sansSerif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Sans";
        };
        serif = {
          package = pkgs.dejavu_fonts;
          name = "DejaVu Serif";
        };
        sizes = {
          applications = 12;
          terminal = 14;
          desktop = 11;
          popups = 12;
        };
      };
    };
  };
}
