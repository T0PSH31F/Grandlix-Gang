{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.vaultwarden-server;
in
{
  options.services.vaultwarden-server = {
    enable = mkEnableOption "Vaultwarden password manager";
  };

  config = mkIf cfg.enable {
    services.vaultwarden = {
      enable = true;
      config = {
        ROCKET_ADDRESS = "0.0.0.0";
        ROCKET_PORT = 8222;
      };
      backupDir = "/var/vaultwarden-backup";
    };

    networking.firewall.allowedTCPPorts = [ 8222 ];

    # Persistence
    environment.persistence."/persist" = mkIf config.layers.layer-10.system.config.impermanence.enable {
      directories = [
        "/var/lib/vaultwarden"
        "/var/vaultwarden-backup"
      ];
    };

    # services.bitwarden-directory-connector-cli = {
    #   enable = true;
    #   #ldap = {
    #   #    ad = false;
    #   #    hostname = "";
    #   #    port = 389;
    #   #     ssl = false;
    #   #     rootPath = "";
    #   #     username = "";
    #   #     startTls = false;
    #   #  };
    # };
    environment.systemPackages = with pkgs; [
      vaultwarden-webvault
      bitwarden-cli
      bitwarden-desktop
      bitwarden-directory-connector
      bitwarden-directory-connector-cli
      bitwarden-menu
    ];
  };
}
