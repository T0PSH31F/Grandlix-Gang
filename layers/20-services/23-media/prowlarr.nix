{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  config = mkIf config.layers.layer-20.services.config.media-stack.enable {
    services.prowlarr = {
      enable = true;
    };

    systemd.services.prowlarr.serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = lib.mkForce config.layers.layer-20.services.config.media-stack.user;
      Group = lib.mkForce config.layers.layer-20.services.config.media-stack.group;
      StateDirectory = lib.mkForce "prowlarr";
      StateDirectoryMode = lib.mkForce "0750";
      PrivateTmp = lib.mkForce false;
      ProtectSystem = lib.mkForce false;
      ProtectHome = lib.mkForce false;
      ReadWritePaths = [ "/var/lib/prowlarr" ];
    };
  };
}
