{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.desktop.noctalia;
in
{
  config = lib.mkIf (cfg.enable && cfg.backend == "hyprland") {
    # IPC helpers (wrap common calls)
    home.packages = [
      cfg.package
      (pkgs.writeShellApplication {
        name = "noctalia-ipc";
        runtimeInputs = [ cfg.package ];
        text = ''
          cmd="$1"; shift
          noctalia-shell ipc "$cmd" "$@"
        '';
      })
      (pkgs.writeShellScriptBin "noctalia-restart" ''
        systemctl --user restart noctalia-shell
      '')
    ];

    # Env vars for Noctalia IPC discovery/integration
    wayland.windowManager.hyprland.settings.env = [
      "NOCTALIA_SOCKET,~/.cache/noctalia/noctalia.sock" # If socket-based
    ];

    # Startup order: Ensure Noctalia starts directly via exec-once in hyprland/default.nix
    # (Moved to hyprland/default.nix to avoid double-launch or systemd timing issues)
  };
}
