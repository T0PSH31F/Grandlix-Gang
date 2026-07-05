# iOS Device Support (usbmuxd, ifuse, libimobiledevice)
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.layers.layer-10.system.mobile.ios;
in
{
  options.layers.layer-10.system.mobile.ios = {
    enable = lib.mkEnableOption "iOS device support (usbmuxd, ifuse)";
  };

  config = lib.mkIf cfg.enable {
    # Enable usbmuxd for USB multiplexing (required for iOS)
    services.usbmuxd.enable = true;

    programs.idescriptor.enable = true;

    environment.systemPackages = with pkgs; [
      libimobiledevice # Communicate with iOS devices
      libirecovery
      libusbmuxd
      usbmuxd2
      ipad_charge
      ifuse # Mount iOS filesystems
      ideviceinstaller # Manage apps
      ios-webkit-debug-proxy # Debug WebKit on iOS
    ];
  };
}
