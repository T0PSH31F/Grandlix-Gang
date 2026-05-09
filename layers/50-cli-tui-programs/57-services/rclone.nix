{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.layers.layer-50.home.cli.services.rclone;
in
{
  options.layers.layer-50.home.cli.services.rclone = {
    enable = mkEnableOption "Rclone Google Drive mount service";
  };

  home = mkIf cfg.enable {
    home.packages = with pkgs; [
      rclone
      fuse
    ];

    systemd.user.services.rclone-gdrive = {
      Unit = {
        Description = "Rclone Google Drive mount";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };

      Service = {
        Type = "simple";
        ExecStartPre = "/run/current-system/sw/bin/mkdir -p %h/GoogleDrive";
        ExecStart = "${pkgs.rclone}/bin/rclone mount google_crypt: %h/GoogleDrive --vfs-cache-mode writes --vfs-cache-max-size 10G";
        ExecStop = "/run/current-system/sw/bin/fusermount -u %h/GoogleDrive";
        Restart = "on-failure";
        RestartSec = "10s";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
