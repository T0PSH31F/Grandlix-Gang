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
  # Stylix is scoped to FONTS ONLY. All color/visual theming is owned by
  # Noctalia (desktop shell) at runtime, which dynamically regenerates
  # Material You colors from the current wallpaper.
  nixos = lib.mkIf (cfg.enable && (inputs ? stylix)) {
    stylix = {
      enable = true;
      # Required by Stylix but not used for theming — Noctalia sets wallpaper at runtime
      image = ../../00-cyberia/02-assets/sddm_background/fallback1.jpg;
      polarity = "dark";
      base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
      homeManagerIntegration.autoImport = true;
      homeManagerIntegration.followSystem = true;

      # ── Disable all targets managed by other modules ──
      # Boot: managed by 32-boot (plymouth-hellonavi, greeter)
      targets.plymouth.enable = false;
      targets.grub.enable = false;
      targets.regreet.enable = false;

      # Cursor: managed by 31-cursor (Sonic Hyprcursor) — no stylix.cursor config set

      # GTK/Qt: managed by 33-gtk, 34-qt, and Noctalia at runtime
      targets.gtk.enable = false;
      targets.qt.enable = false;

      # Console: managed by Noctalia at runtime
      targets.console.enable = false;

      # ── Fonts: the only thing Stylix owns ──
      fonts = {
        monospace = {
          package = pkgs.nerd-fonts.jetbrains-mono;
          name = "JetBrainsMono Nerd Font";
        };
        sansSerif = {
          package = pkgs.nerd-fonts.noto;
          name = "Noto Sans Nerd Font";
        };
        serif = {
          package = pkgs.nerd-fonts.noto;
          name = "Noto Serif Nerd Font";
        };
        emoji = {
          package = pkgs.twitter-color-emoji;
          name = "Twitter Color Emoji";
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

  # 2. Home Manager — disable all app-level Stylix targets
  # Noctalia handles runtime theming for all of these
  home = lib.mkIf (cfg.enable && (inputs ? stylix)) {
    stylix.targets = {
      firefox.enable = false;
      kitty.enable = false;
      ghostty.enable = false;
      helix.enable = false;
      btop.enable = false;
      fzf.enable = false;
      bat.enable = false;
      yazi.enable = false;
      zellij.enable = false;
      rofi.enable = false;
      hyprland.enable = false;
      swaync.enable = false;
      gtk.enable = false;
      qt.enable = false;
    };
  };
}
