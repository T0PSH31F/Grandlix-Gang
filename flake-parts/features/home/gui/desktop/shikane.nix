{
  pkgs,
  lib,
  osConfig,
  ...
}:
let
  clanTags = osConfig.machine.tags or [ ];
in
{
  config = lib.mkIf (builtins.elem "desktop" clanTags) {
    # Re-enabled for automatic monitor profiling
    home.packages = [ pkgs.shikane ];

    xdg.configFile."shikane/config.toml" = {
      force = true;
      text = ''
        [[profile]]
        name = "triple"
        # Triple monitor setup with eDP-1 in the middle, top-aligned
        [[profile.output]]
        search = "DP-1"
        enable = true
        mode = "1920x1080@60"
        position = "0,0"
        scale = 1.0

        [[profile.output]]
        search = "eDP-1"
        enable = true
        mode = "2560x1600@60"
        position = "1920,0" # Top aligned
        scale = 1.6

        [[profile.output]]
        search = "HDMI-A-1"
        enable = true
        mode = "3840x2160@30"
        position = "3520,0"
        scale = 2.0

        [[profile]]
        name = "big-screen"
        # Match a single large external monitor (60" TV - 1080p)
        [[profile.output]]
        search = "HDMI-A-1"
        enable = true
        mode = "1920x1080@60"
        position = "0,0"
        scale = 1.0

        [[profile.output]]
        search = "eDP-1"
        enable = true
        mode = "2560x1600@60"
        position = "1920,0" # Next to the 1080p screen, top-aligned
        scale = 1.6

        [[profile]]
        name = "clamshell"
        # For general dual-monitor clamshell
        [[profile.output]]
        search = "HDMI-A-1"
        enable = true
        mode = "3840x2160@30"
        position = "0,0"
        scale = 2.0

        [[profile.output]]
        search = "DP-1"
        enable = true
        mode = "1920x1080@60"
        position = "1920,0"
        scale = 1.0

        [[profile]]
        name = "laptop"
        [[profile.output]]
        search = "eDP-1"
        enable = true
        mode = "2560x1600@60"
        position = "0,0"
        scale = 1.6
      '';
    };
    systemd.user.services.shikane = {
      Unit = {
        Description = "Dynamic output configuration for Wayland";
        Documentation = "https://gitlab.com/w0lff/shikane";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.shikane}/bin/shikane";
        Restart = "always";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
