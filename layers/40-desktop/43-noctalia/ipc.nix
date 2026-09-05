{
  osConfig ? config,
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = osConfig.layers.layer-40.desktop.noctalia;
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.package
      (pkgs.writeShellApplication {
        name = "noctalia-ipc";
        runtimeInputs = [ cfg.package ];
        text = ''
          cmd="$1"; shift
          noctalia msg "$cmd" "$@"
        '';
      })
      (pkgs.writeShellScriptBin "noctalia-restart" ''
        systemctl --user restart noctalia
      '')
      (pkgs.writeShellScriptBin "noctalia-wallpaper-set" ''
        noctalia msg wallpaper-set "$@"
      '')
      (pkgs.writeShellScriptBin "noctalia-theme-toggle" ''
        noctalia msg theme-mode-toggle
      '')
      (pkgs.writeShellScriptBin "noctalia-templates-apply" ''
        noctalia msg templates-apply
      '')
      (pkgs.writeShellScriptBin "noctalia-color-scheme" ''
        noctalia msg color-scheme-set "$@"
      '')
    ];

    wayland.windowManager.hyprland.settings.env =
      lib.mkIf (cfg.backend == "hyprland" || cfg.backend == "both")
        [
          "NOCTALIA_SOCKET,~/.cache/noctalia/noctalia.sock"
        ];
  };
}
