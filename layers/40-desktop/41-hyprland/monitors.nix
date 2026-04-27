{ osConfig ? config, 
  config,
  lib,
  ...
}:
let
  cfg = osConfig.features.desktop.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {

      # ── Monitor Configuration ──────────────────────────────────────────
      # Sourced from nwg-displays (managed manually via GUI)

      # Static monitor configuration (fallback if nwg-displays/shikane is inactive)
      monitor = [
        "DP-1, 3840x2160@30, 0x0, 2.0"
        "eDP-1, 2560x1600@60, 1920x0, 1.6"
        "HDMI-A-1, 1920x1080@60, 3520x0, 1"
        ",preferred,auto,1"
      ];

      # ── Workspace Assignments ────────────────────────────────────────
      # Persistent workspaces per monitor
      workspace = [
        "1, monitor:eDP-1, default:true, persistent:true"
        "2, monitor:eDP-1, persistent:true"
        "3, monitor:eDP-1, persistent:true"
        "4, monitor:eDP-1, persistent:true"
        "5, monitor:eDP-1, persistent:true"

        "6, monitor:DP-1, default:true, persistent:true"
        "7, monitor:DP-1, persistent:true"
        "8, monitor:DP-1, persistent:true"
        "9, monitor:DP-1, persistent:true"
        "10, monitor:HDMI-A-1, default:true, persistent:true"

        "special:scratchpad, on-created-empty:hx"
      ];
    };
  };
}
