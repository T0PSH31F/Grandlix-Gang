{
  osConfig ? config,
  config,
  lib,
  ...
}:
let
  cfg = osConfig.layers.layer-40.desktop.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {

      # ── Monitor Configuration ──────────────────────────────────────────
      # Sourced from nwg-displays (managed manually via GUI)
      # This sources ~/.config/hypr/monitors.conf

      # Safety override for NVIDIA legacy drivers (prevents GBM format mismatch crashes)
      # Forces 8-bit depth (XRGB8888) as default for any monitor not explicitly matched.
      monitor = lib.mkIf cfg.isNvidia [
        ",preferred,auto,1,bitdepth,8"
      ];

      # We leave 'monitor' and 'workspace' assignments empty here to allow
      # nwg-displays to take full control via the sourced file.
    };
  };
}
