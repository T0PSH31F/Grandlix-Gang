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
