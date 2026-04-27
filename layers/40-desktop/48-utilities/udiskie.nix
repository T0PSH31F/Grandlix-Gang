{ lib, config, ... }: {
  options.features.desktop.udiskie = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.hardware-config.automount.enable or false;
      description = "Enable udiskie automounter";
    };
  };

  home = lib.mkIf config.features.desktop.udiskie.enable {
    services.udiskie = {
      enable = true;
      tray = "auto";
      notify = true;
    };
  };
}
