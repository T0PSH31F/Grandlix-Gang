# Unified Peripherals Module for Physical Hardware Systems
{
  config,
  lib,
  pkgs,
  osConfig ? config,
  ...
}:
let
  cfg = osConfig.layers.layer-10.system.peripherals;
  clanTags = osConfig.machine.tags or [ ];
in
{
  imports = [
    ./bluetooth.nix
    ./razer.nix
    ./touchpad.nix
  ];

  options.layers.layer-10.system.peripherals = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = builtins.elem "workstation" clanTags || builtins.elem "laptop" clanTags || builtins.elem "desktop" clanTags;
      description = "Master enable toggle for all physical hardware peripherals";
    };

    controllers = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable controller drivers and support (Xbox, PlayStation, etc.)";
      };
    };

    bluetooth = {
      enable = lib.mkEnableOption "Bluetooth support";
    };

    corsair = {
      enable = lib.mkEnableOption "Corsair hardware support (ckb-next)";
    };

    openrgb = {
      enable = lib.mkEnableOption "OpenRGB for RGB lighting control";
      enableI2C = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable I2C support for RGB RAM and motherboards";
      };
    };

    automount = {
      enable = lib.mkEnableOption "Automatic disk mounting with udisks2/udiskie";
      useUdiskie = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Use udiskie for automatic mounting (userspace). If false, uses udisks2 only.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # 1. Enable sub-peripherals by default under the master switch
    layers.layer-10.system.peripherals = {
      bluetooth.enable = lib.mkDefault true;
      touchpad.enable = lib.mkDefault (builtins.elem "laptop" clanTags);
      razer.enable = lib.mkDefault true;
    };

    # 2. Controllers integration (Xbox, PlayStation Dualshock/DualSense, etc.)
    hardware.xone.enable = lib.mkIf cfg.controllers.enable (lib.mkDefault true);
    hardware.xpadneo.enable = lib.mkIf cfg.controllers.enable (lib.mkDefault true);

    services.udev.packages = lib.mkIf cfg.controllers.enable (with pkgs; [
      game-devices-udev-rules
    ]);
  };
}
