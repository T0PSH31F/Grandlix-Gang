{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.layers.layer-10.system.peripherals.razer;
in
{
  options.layers.layer-10.system.peripherals.razer = {
    enable = mkEnableOption "Razer peripheral support (OpenRazer)";

    user = mkOption {
      type = types.str;
      default = "t0psh31f";
      description = "User to add to openrazer group";
    };

    enablePolychromatic = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Polychromatic GUI for RGB control";
    };
  };



    # OpenRazer disabled due to kernel incompatibility; no packages, groups, or udev rules are added.

}
