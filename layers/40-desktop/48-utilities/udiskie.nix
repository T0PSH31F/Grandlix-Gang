{ lib, config, ... }: {
  options.layers.layer-40.desktop.udiskie = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.hardware-config.automount.enable or false;
      description = "Enable udiskie automounter";
    };
  };

  home = lib.mkIf config.layers.layer-40.desktop.udiskie.enable {
    services.udiskie = {
      enable = true;
      tray = "auto";
      notify = true;
    };
  };
}
