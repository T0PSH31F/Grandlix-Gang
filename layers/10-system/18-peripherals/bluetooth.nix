{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.layers.layer-10.system.peripherals.bluetooth;
in
{
  config = lib.mkIf cfg.enable {
    # Enable Bluetooth
    hardware.bluetooth = {
      enable = lib.mkDefault true;
      powerOnBoot = lib.mkDefault true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
        Policy = {
          AutoEnable = true;
        };
      };
    };

    # Bluetooth services
    services.blueman.enable = true;

    # Prevent Bluetooth USB controllers from auto-suspending (turning off on idle)
    services.udev.extraRules = ''
      # Disable USB autosuspend for Bluetooth controllers by driver name and class
      ACTION=="add", SUBSYSTEM=="usb", DRIVERS=="btusb", ATTR{power/control}="on"
      ACTION=="add", SUBSYSTEM=="usb", ATTRS{bInterfaceClass}=="e0", ATTRS{bInterfaceSubClass}=="01", ATTRS{bInterfaceProtocol}=="01", ATTR{power/control}="on"
    '';

    # Prevent TLP from turning off bluetooth on boot or when switching power sources
    services.tlp.settings = lib.mkIf (config.services.tlp.enable or false) {
      DEVICES_TO_DISABLE_ON_STARTUP = "none";
      DEVICES_TO_DISABLE_ON_BAT_NOT_IN_USE = "none";
      DEVICES_TO_DISABLE_ON_LAN_CONNECT = "none";
      DEVICES_TO_DISABLE_ON_WIFI_CONNECT = "none";
      DEVICES_TO_DISABLE_ON_WWAN_CONNECT = "none";
      DEVICES_TO_ENABLE_ON_STARTUP = "bluetooth";
      DEVICES_TO_ENABLE_ON_AC = "bluetooth";
      DEVICES_TO_ENABLE_ON_BAT = "bluetooth";
    };

    # Bluetooth packages
    environment.systemPackages = with pkgs; [
      bluez
      bluez-tools
      blueman
      bluetuith
    ];

    # Auto-connect trusted devices
    systemd.user.services.bluetooth-auto-connect = {
      description = "Auto-connect Bluetooth devices";
      after = [ "bluetooth.service" ];
      partOf = [ "bluetooth.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c '${pkgs.coreutils}/bin/timeout 10 ${pkgs.bluez}/bin/bluetoothctl connect-all || true'";
        RemainAfterExit = true;
      };
      wantedBy = [ "default.target" ];
    };
  };
}
