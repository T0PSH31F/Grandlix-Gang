{
  config,
  lib,
  pkgs,
  ...
}:
let
  periph = config.layers.layer-10.system.peripherals;
in
{
  config = lib.mkMerge [
    (lib.mkIf periph.openrgb.enable {
      services.hardware.openrgb.enable = true;
      hardware.i2c.enable = lib.mkIf periph.openrgb.enableI2C true;
      environment.systemPackages = with pkgs; [ openrgb ];
    })

    (lib.mkIf periph.corsair.enable {
      hardware.ckb-next.enable = true;
    })
  ];
}
