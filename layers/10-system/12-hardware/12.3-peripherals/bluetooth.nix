{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.system.hardware.bluetooth;
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
        Type = "forking";
        ExecStart = "${pkgs.bluez}/bin/bluetoothctl connect-all";
        RemainAfterExit = true;
      };
      wantedBy = [ "default.target" ];
    };
  };
}
