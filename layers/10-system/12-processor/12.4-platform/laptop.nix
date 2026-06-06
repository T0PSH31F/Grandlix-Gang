{
  config,
  lib,
  pkgs,
  ...
}:
let
  hasTag = tag: builtins.elem tag (config.machine.tags or [ ]);
in
{
  config = lib.mkIf (hasTag "laptop") {
    # Laptop-specific hardware configuration
    # Desktop environment setup is handled separately in flake-parts/desktop/

    # Power Management
    services.power-profiles-daemon.enable = lib.mkDefault true;
    services.upower.enable = lib.mkDefault true;

    # Touchpad support
    services.libinput.enable = lib.mkDefault true;
    services.libinput.touchpad.tapping = lib.mkDefault true;
    services.libinput.touchpad.naturalScrolling = lib.mkDefault true;
    # Keyboard Backlight Control
    environment.systemPackages = [ pkgs.brightnessctl ];

    # Turn on keyboard backlight on boot
    systemd.services.keyboard-backlight = {
      description = "Turn on keyboard backlight";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c 'echo 255 > /sys/class/leds/kbd_backlight/brightness || true'";
      };
    };
  };
}
