# hypridle — DPMS screen-off for Hyprland (replaces noctalia's buggy idle)
#
# Noctalia's native idle system triggers DPMS screen-off internally, but on
# Intel Iris Xe (Alder Lake) the Wayland compositor connection breaks when
# the display wakes, causing noctalia to crash with "Broken pipe" and kill
# all running programs. hypridle is Hyprland-native and handles DPMS
# transitions cleanly without the connection-breaking behaviour.
{
  osConfig ? config,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = osConfig.layers.layer-40.desktop.noctalia;
in
{
  config = lib.mkIf (cfg.enable && cfg.backend == "hyprland") {
    home.packages = [ pkgs.hypridle ];

    xdg.configFile."hypr/hypridle.conf" = {
      text = ''
        # hypridle — idle management for Hyprland
        #
        # Replaces noctalia's built-in idle handler which caused DPMS-related
        # Wayland crashes on Intel Iris Xe. See layers/40-desktop/43-noctalia/hypridle.nix.

        general {
            lock_cmd = pidof hyprlock || hyprlock;  # lock if hyprlock installed
            before_sleep_cmd = loginctl lock-session; # lock before system suspend
            after_sleep_cmd = hyprctl dispatch dpms on; # wake display after suspend
        }

        listener {
            timeout = 600;                            # 10 minutes
            on-timeout = hyprctl dispatch dpms off;  # turn off display
            on-resume = hyprctl dispatch dpms on;    # turn on display
        }

        listener {
            timeout = 660;                            # 11 minutes
            on-timeout = loginctl lock-session;       # lock session
        }
      '';
    };

    systemd.user.services.hypridle = {
      Unit = {
        Description = "Hyprland idle daemon (DPMS + lock)";
        Documentation = "https://github.com/hyprwm/hypridle";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.hypridle}/bin/hypridle";
        Restart = "on-failure";
        RestartSec = "5s";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
