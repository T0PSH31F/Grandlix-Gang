{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.layers.layer-10.system.mobile;
in
{
  options.layers.layer-10.system.mobile = {
    android = {
      enable = mkEnableOption "Android device support (ADB, Waydroid)";
    };
    ios = {
      enable = mkEnableOption "iOS device support (usbmuxd, ifuse)";
    };
  };

  config = mkMerge [
    # ============================================================================
    # ANDROID SUPPORT
    # ============================================================================
    (mkIf cfg.android.enable {

      # File Transfer & MTP
      # services.gvfs.enable = true; # Mount, Trash, and other functionalities
      environment.systemPackages = with pkgs; [
        android-tools # ADB, Fastboot
        jmtpfs # MTP Filesystem
        scrcpy # Screen mirroring
        heimdall-gui # GUI for Heimdall (provides CLI tools as well)
        mtkclient
        mobile-broadband-provider-info
        qmk-udev-rules
        phonemizer
        pixelflasher
        universal-android-debloater
        valent # KDE Connect implementation for GTK
      ];

      # Open ports for KDE Connect protocol (used by Valent)
      networking.firewall = {
        allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
        allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
      };

      # User permissions
      # Ensure users are in 'adbusers' group in user config
    })

    # ============================================================================
    # iOS SUPPORT
    # ============================================================================
    (mkIf cfg.ios.enable {
      # Enable usbmuxd for USB multiplexing (required for iOS)
      services.usbmuxd.enable = true;

      programs.idescriptor.enable = true;

      environment.systemPackages = with pkgs; [
        libimobiledevice # Communicate with iOS devices
        libirecovery
        ipad_charge
        ifuse # Mount iOS filesystems
        ideviceinstaller # Manage apps
        ios-webkit-debug-proxy # Debug WebKit on iOS
      ];
    })

    # ============================================================================
    # COMMON MOBILE INTEGRATION
    # ============================================================================
    (mkIf (cfg.android.enable || cfg.ios.enable) {
      # KDE Connect / GSConnect
      # Allows wireless file transfer, clipboard sync, notifications
      programs.kdeconnect.enable = true;
    })
  ];
}
