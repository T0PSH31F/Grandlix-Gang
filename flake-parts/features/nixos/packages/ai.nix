# flake-parts/features/nixos/packages/ai.nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  hasTag = tag: builtins.elem tag (config.machine.tags or [ ]);
in
{
  options.services.hyprwhspr-rs = {
    enable = lib.mkEnableOption "HyprWhspr whisper backend service";
  };

  config = lib.mkMerge [
    (lib.mkIf (hasTag "ai-server") {
      environment.systemPackages = with pkgs; [
        ollama
        hyprwhspr-rs
      ];
    })
    (lib.mkIf config.services.hyprwhspr-rs.enable {
      systemd.user.services.hyprwhspr-rs = {
        Unit = {
          Description = "HyprWhspr whisper backend";
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.hyprwhspr-rs}/bin/hyprwhspr-rs";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    })
  ];
}
