# AdGuard Home DNS Service
# layers/nixos/services/adguard.nix
{
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.layers.layer-20.services.config.adguard;
in
{
  options.layers.layer-20.services.config.adguard = {
    enable = mkEnableOption "AdGuard Home DNS filtering";

    port = mkOption {
      type = types.port;
      default = 3001;
      description = "Web interface port";
    };

    dnsPort = mkOption {
      type = types.port;
      default = 53;
      description = "DNS server port";
    };
  };

  config = mkIf cfg.enable {
    services.adguardhome = {
      enable = true;
      openFirewall = true;
      mutableSettings = true;
      settings = {
        http = {
          address = "0.0.0.0:${toString cfg.port}";
        };
        dns = {
          bind_hosts = [ "0.0.0.0" ];
          port = cfg.dnsPort;
          bootstrap_dns = [
            "9.9.9.9"
            "1.1.1.1"
          ];
          upstream_dns = [
            "https://dns.quad9.net/dns-query"
            "https://cloudflare-dns.com/dns-query"
          ];
        };
        filtering = {
          rewrites = [ ];
        };
      };
    };

    # Fix StateDirectory conflict with impermanence
    systemd.services.adguardhome.serviceConfig.StateDirectory = lib.mkForce [ ];

    # Impermanence support
    environment.persistence."/persist" = mkIf config.layers.layer-10.system.config.impermanence.enable {
      directories = [
        {
          directory = "/var/lib/AdGuardHome";
          user = "adguardhome";
          group = "adguardhome";
          mode = "0700";
        }
      ];
    };
  };
}
