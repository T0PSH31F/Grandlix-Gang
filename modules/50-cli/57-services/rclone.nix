# flake-parts/features/home/cli/services/rclone.nix
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.features.home.cli.services.rclone;
in
{
  options.features.home.cli.services.rclone = {
    enable = mkEnableOption "Rclone Google Drive mount service";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      rclone
      fuse
    ];

    # rclone.conf is expected to be at ~/.config/rclone/rclone.conf
    # This will be populated via Clan secrets.
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
