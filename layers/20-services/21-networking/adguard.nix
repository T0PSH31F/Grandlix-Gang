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
      default = 3002;
      description = "Web interface port";
    };

    dnsPort = mkOption {
      type = types.port;
      default = 53;
      description = "DNS server port";
    };

    bindHosts = mkOption {
      type = types.listOf types.str;
      default = [ "0.0.0.0" ];
      description = "IP addresses AdGuard Home should bind its DNS server to";
    };
  };

  config = mkIf cfg.enable {
    # Disable systemd-resolved listener to free up port 53 for AdGuard Home
    services.resolved.settings = {
      Resolve = {
        DNSStubListener = "no";
      };
    };

    services.adguardhome = {
      enable = true;
      openFirewall = true;
      port = cfg.port;
      mutableSettings = true;
      settings = {
        dns = {
          bind_hosts = cfg.bindHosts;
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

    # Fix StateDirectory conflict with impermanence by using static user
    systemd.services.adguardhome = {
      environment.STATE_DIRECTORY = "/var/lib/AdGuardHome";
      serviceConfig = {
        DynamicUser = lib.mkForce false;
        StateDirectory = lib.mkForce [ ];
        ReadWritePaths = [ "/var/lib/AdGuardHome" ];
      };
    };

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
