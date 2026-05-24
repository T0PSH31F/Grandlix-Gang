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
