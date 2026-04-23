{
  config,
  lib,
  ...
}:
let
  cfg = config.desktop.noctalia;
in
{
  config = lib.mkIf (cfg.enable && (cfg.backend == "niri" || cfg.backend == "both")) {
    # uwsm environment variables for Niri
    xdg.configFile."uwsm/env-niri".text = ''
      export XDG_CURRENT_DESKTOP=niri
      export XDG_SESSION_TYPE=wayland
      export XDG_SESSION_DESKTOP=niri
      export ELECTRON_OZONE_PLATFORM_HINT=auto
    '';

    # Also ensure the general uwsm/env is active for niri
    # (Since it's in hyprland/uwsm.nix currently, we should move common ones to a shared location,
    # but for now we replicate the essential wayland ones)
    xdg.configFile."uwsm/env".text = lib.mkDefault ''
      export GDK_BACKEND=wayland,x11,*
      export QT_QPA_PLATFORM="wayland;xcb"
      export SDL_VIDEODRIVER=wayland
      export CLUTTER_BACKEND=wayland
      export QT_AUTO_SCREEN_SCALE_FACTOR=1
      export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      export QT_QPA_PLATFORMTHEME=qt5ct
    '';

    # Desktop Entry for UWSM managed Niri session (as requested)
    home.file.".local/share/wayland-sessions/niri-uwsm.desktop".text = ''
      [Desktop Entry]
      Name=Niri (UWSM)
      Comment=Niri compositor managed by UWSM
      Exec=uwsm start -F -- niri --session
      DesktopNames=niri
      Type=Application
    '';
  };
}
