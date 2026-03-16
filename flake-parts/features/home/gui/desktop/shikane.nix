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
    # Disabled in favor of nwg-displays for manual control
    # home.packages = [ pkgs.shikane ];

    xdg.configFile."shikane/config.toml" = {
      force = true;
      text = ''
        [[profile]]
        name = "triple"
        # Acer Predator 27" (Left)
        [[profile.output]]
        search = "HDMI-A-1"
        enable = true
        mode = "3840x2160@30"
        position = "0,0"
        scale = 2.0

        # Laptop (Center)
        [[profile.output]]
        search = "eDP-1"
        enable = true
        mode = "2560x1600@60"
        position = "1920,0"
        scale = 1.6

        # HKC 27" Curved (Right)
        [[profile.output]]
        search = "DP-2"
        enable = true
        mode = "1920x1080@60"
        position = "3520,0"
        scale = 1.0

        [[profile]]
        name = "clamshell"
        # Acer Predator 27" (Left)
        [[profile.output]]
        search = "HDMI-A-1"
        enable = true
        mode = "3840x2160@30"
        position = "0,0"
        scale = 2.0

        # HKC 27" Curved (Right)
        [[profile.output]]
        search = "DP-2"
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
    # systemd.user.services.shikane = {
    #   Unit = {
    #     Description = "Dynamic output configuration for Wayland";
    #     Documentation = "https://gitlab.com/w0rp/shikane";
    #     PartOf = [ "graphical-session.target" ];
    #     After = [ "graphical-session.target" ];
    #   };
    #   Service = {
    #     ExecStart = "${pkgs.shikane}/bin/shikane";
    #     Restart = "always";
    #   };
    #   Install = {
    #     WantedBy = [ "graphical-session.target" ];
    #   };
    # };
  };
}
