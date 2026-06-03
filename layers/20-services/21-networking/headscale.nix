{ config, lib, ... }:
with lib;
let
  cfg = config.services.headscale-server;
in
{
  options.services.headscale-server = {
    enable = mkEnableOption "Headscale Tailscale control server";
    port = mkOption {
      type = types.port;
      default = 8086;
    };
  };

  config = mkIf cfg.enable {
    services.headscale = {
      enable = true;
      port = cfg.port;
      address = "0.0.0.0";
      settings = {
        dns = {
          magic_dns = true;
          base_domain = "grandlix.net";
          nameservers = {
            global = [
              "1.1.1.1"
              "1.0.0.1"
            ];
          };
        };
        server_url = "http://localhost:${toString cfg.port}";
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];

    systemd.services.headscale.serviceConfig.DynamicUser = lib.mkForce false;

    users.users.headscale = {
      group = "headscale";
      isSystemUser = true;
      home = "/var/lib/headscale";
      createHome = true;
    };
    users.groups.headscale = { };

    systemd.tmpfiles.rules = [
      "d /var/lib/headscale 0750 headscale headscale -"
    ];

    # Persistence
    environment.persistence."/persist" = mkIf config.layers.layer-10.system.config.impermanence.enable {
      directories = [ "/var/lib/headscale" ];
    };
  };
}
