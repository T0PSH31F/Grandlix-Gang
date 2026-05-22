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
    clan.core.vars.generators.vaultwarden = {
      files."vaultwarden.env" = {
        secret = true;
      };
      script = ''
        TOKEN=$(${pkgs.openssl}/bin/openssl rand -hex 32)
        echo "ADMIN_TOKEN=$TOKEN" > "$out/vaultwarden.env"
      '';
    };

    services.vaultwarden = {
      enable = true;
      environmentFile = config.clan.core.vars.generators.vaultwarden.files."vaultwarden.env".path;
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
