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

    dhcp = mkOption {
      type = types.bool;
      default = false;
      description = "Enable AdGuard Home DHCP server";
    };

    lanInterface = mkOption {
      type = types.str;
      default = "eth1";
      description = "LAN interface for DHCP";
    };

    gatewayIp = mkOption {
      type = types.str;
      default = "192.168.1.54";
      description = "Luffy's LAN IP (for DNS rewrites and DHCP gateway field)";
    };

    subnet = mkOption {
      type = types.str;
      default = "192.168.1.0/24";
      description = "LAN subnet";
    };

    dhcpRange = mkOption {
      type = types.listOf types.str;
      default = [ "192.168.1.100" "192.168.1.250" ];
      description = "DHCP lease range (only used if dhcp = true)";
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
      allowDHCP = cfg.dhcp;
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
          rewrites = [
            { domain = "*.lovelain.duckdns.org"; answer = cfg.gatewayIp; }
          ];
        };
        filters = [
          { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt"; name = "AdGuard DNS filter"; }
          { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"; name = "AdGuard DNS filter (mobile)"; }
          { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt"; name = "AdGuard Base filter"; }
          { enabled = true; url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt"; name = "AdGuard Base filter (mobile)"; }
        ];
        dhcp = mkIf cfg.dhcp {
          enabled = true;
          interface = cfg.lanInterface;
          range = cfg.dhcpRange;
          lease_time = 86400;
          gateway = cfg.gatewayIp;
        };
      };
    };

    users.users.adguardhome = {
      isSystemUser = true;
      group = "adguardhome";
      description = "AdGuard Home Daemon User";
      home = "/var/lib/AdGuardHome";
    };
    users.groups.adguardhome = { };

    # Fix StateDirectory conflict with impermanence by using static user
    systemd.services.adguardhome = {
      after = [
        "network-online.target"
        "persist.mount"
      ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = lib.mkForce "adguardhome";
        Group = lib.mkForce "adguardhome";
        ReadWritePaths = lib.mkForce [ "/var/lib/AdGuardHome" ];
        Restart = lib.mkForce "always";
        RestartSec = lib.mkForce "10s";
        StartLimitIntervalSec = lib.mkForce 0;
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
