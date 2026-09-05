# Unified QT Theming Module
{
  config,
  lib,
  pkgs,
  osConfig ? config,
  ...
}:
{
  options.layers.layer-30.theming.qt = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable QT application theming and style integration";
    };
  };

  # Home Manager QT configuration
  home =
    let
      cfg = osConfig.layers.layer-30.theming.qt;
    in
    lib.mkIf cfg.enable {
      home.packages = with pkgs; [
        qt5.qtwayland
        qt6.qtwayland
        qt6Packages.qt5compat
        qt6Packages.qt6ct
      ];

      qt = {
        enable = true;
        platformTheme.name = "qtct";
        style.name = "kvantum";
      };
    };
}
