{
  config,
  lib,
  ...
}:
let
  cfg = config.desktop.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {

      # ── Monitor Configuration ──────────────────────────────────────────
      # Vertical Layout: 60" TV on top, HDMI-A-1 and eDP-1 on bottom
      monitor = [
        "DP-2, 3840x2160@60, 0x0, 1"
        "HDMI-A-1, 1920x1080@60, 0x2160, 1"
        "eDP-1, 1920x1080@60, 1920x2160, 1"
        ",preferred,auto,1"
      ];

      # ── Workspace Assignments ────────────────────────────────────────
      # Persistent workspaces per monitor
      workspace = [
        "1, monitor:HDMI-A-1, default:true, persistent:true"
        "2, monitor:HDMI-A-1, persistent:true"
        "3, monitor:HDMI-A-1, persistent:true"

        "4, monitor:eDP-1, default:true, persistent:true"
        "5, monitor:eDP-1, persistent:true"
        "6, monitor:eDP-1, persistent:true"

        "7, monitor:DP-2, default:true, persistent:true"
        "8, monitor:DP-2, persistent:true"
        "9, monitor:DP-2, persistent:true"

        "special:scratchpad, on-created-empty:hx"
      ];
    };
  };
}
