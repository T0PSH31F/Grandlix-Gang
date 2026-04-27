 {
  config,
  lib,
  ...
}:
with lib;
{
  options.services.caddy-server = {
    enable = mkEnableOption "Caddy web server";

    email = mkOption {
      type = types.str;
      default = "";
      description = "Email for Let's Encrypt certificates";
    };

    virtualHosts = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            extraConfig = mkOption {
              type = types.lines;
              default = "";
              description = "Extra Caddy configuration";
            };
            useACMEHost = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Use ACME certificate for this host";
            };
            serverAliases = mkOption {
              type = types.listOf types.str;
              default = [ ];
              description = "Alternative names for this host";
            };
          };
        }
      );
      default = { };
      description = "Virtual hosts configuration";
    };
  };

  config = mkIf config.services.caddy-server.enable {
    services.caddy = {
      enable = true;

      globalConfig = mkIf (config.services.caddy-server.email != "") ''
        email ${config.services.caddy-server.email}
      '';

      virtualHosts = mapAttrs
        (name: value: {
          inherit (value) extraConfig useACMEHost serverAliases;
        })
        config.services.caddy-server.virtualHosts;
    };

    # Firewall
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    networking.firewall.allowedUDPPorts = [ 443 ]; # For QUIC

    # Ensure data is persisted
    environment.persistence."/persist" = mkIf config.features.system.config.impermanence.enable {
      directories = [
        "/var/lib/caddy"
      ];
    };
  };
}
