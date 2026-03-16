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
      # Sourced from nwg-displays (managed manually via GUI)
      source = [ "~/.config/hypr/monitors.conf" ];

      # Static monitor configuration (fallback if nwg-displays file is missing)
      monitor = [
        "eDP-1, 2560x1600@60, 0x0, 1.6"
        "DP-1, 1920x1080@60, 1600x0, 1"
        "DP-2, 1920x1080@60, 1600x0, 1"
        ",preferred,auto,1"
      ];

      # ── Workspace Assignments ────────────────────────────────────────
      # Persistent workspaces per monitor
      workspace = [
        "1, monitor:eDP-1, default:true, persistent:true"
        "2, monitor:eDP-1, persistent:true"
        "3, monitor:eDP-1, persistent:true"
        "4, monitor:eDP-1, persistent:true"

        "5, monitor:DP-1, default:true, persistent:true"
        "5, monitor:DP-2, default:true, persistent:true"
        "6, monitor:DP-1, persistent:true"
        "6, monitor:DP-2, persistent:true"
        "7, monitor:DP-1, persistent:true"
        "7, monitor:DP-2, persistent:true"
        "8, monitor:DP-1, persistent:true"
        "8, monitor:DP-2, persistent:true"
        "9, monitor:DP-1, persistent:true"
        "9, monitor:DP-2, persistent:true"
        "10, monitor:DP-1, persistent:true"
        "10, monitor:DP-2, persistent:true"

        "special:scratchpad, on-created-empty:hx"
      ];
    };
  };
}
