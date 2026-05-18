# Unified GTK Theming Module
{
  config,
  lib,
  pkgs,
  osConfig ? config,
  ...
}:
let
  cfg = osConfig.layers.layer-30.theming.gtk;
in
{
  options.layers.layer-30.theming.gtk = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = builtins.elem "desktop" (osConfig.machine.tags or [ ]);
      description = "Enable GTK theming engine and configuration";
    };
  };

  # Home Manager GTK configuration
  home = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      adw-gtk3
      nwg-look
      candy-icons
      hicolor-icon-theme
    ];

    gtk = lib.mkIf (!(config.stylix.enable or false)) {
      enable = true;
      theme = {
        name = "adw-gtk3-dark";
        package = pkgs.adw-gtk3;
      };
      iconTheme = {
        name = "candy-icons";
        package = pkgs.candy-icons;
      };
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };
  };
}
