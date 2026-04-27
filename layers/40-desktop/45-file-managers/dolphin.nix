{ pkgs, lib, config, ... }: {
  options.features.desktop.dolphin = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Dolphin file manager";
    };
  };

  home = lib.mkIf config.features.desktop.dolphin.enable {
    home.packages = with pkgs; [
      kdePackages.dolphin
      kdePackages.dolphin-plugins
    ];
  };
}
