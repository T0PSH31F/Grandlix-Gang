{ pkgs, ... }:
let
  user = "t0psh31f";
  mountPoint = "/home/${user}/GoogleDrive";
in
{
  environment.systemPackages = [ pkgs.rclone ];
  environment.persistence."/persist".users.${user}.directories = [ ".config/rclone" ];
  systemd.services.rclone-gdrive-mount = {
    description = "Mount Google Drive via rclone";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = user;
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${mountPoint}";
      ExecStart = "${pkgs.rclone}/bin/rclone mount gdrive: ${mountPoint} --vfs-cache-mode full";
      ExecStop = "/run/current-system/sw/bin/fusermount -u ${mountPoint}";
      Restart = "on-failure";
    };
  };
}
