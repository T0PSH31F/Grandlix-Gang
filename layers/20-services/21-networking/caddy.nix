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

  options.layers.layer-20.services.config.reverseProxy = {
    routes = mkOption {
      type = types.attrsOf types.int;
      default = {};
      description = "Registry of subdomains to localhost ports. E.g. { ollama = 11434; }";
    };
  };

  config = mkIf config.services.caddy-server.enable {
    services.caddy = {
      enable = true;

      globalConfig = mkIf (config.services.caddy-server.email != "") ''
        email ${config.services.caddy-server.email}
      '';

      virtualHosts = let
        baseVirtualHosts = mapAttrs
          (name: value: {
            inherit (value) extraConfig useACMEHost serverAliases;
          })
          config.services.caddy-server.virtualHosts;
          
        registryRoutes = {
          "*.${config.layers.meta.domain or "lovelain.duckdns.org"}" = {
            useACMEHost = config.layers.meta.domain or "lovelain.duckdns.org";
            extraConfig = ''
              encode zstd gzip
              header Strict-Transport-Security "max-age=31536000; includeSubDomains"
              
              ${concatStringsSep "\n" (mapAttrsToList (subdomain: port: ''
                @${subdomain} host ${subdomain}.${config.layers.meta.domain or "lovelain.duckdns.org"}
                handle @${subdomain} { reverse_proxy localhost:${toString port} }
              '') config.layers.layer-20.services.config.reverseProxy.routes)}
            '';
          };
        };
      in 
        if config.layers.layer-20.services.config.reverseProxy.routes != {} 
        then lib.mkMerge [ baseVirtualHosts registryRoutes ]
        else baseVirtualHosts;
    };

    # Firewall
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
    networking.firewall.allowedUDPPorts = [ 443 ]; # For QUIC

    # Ensure data is persisted
    environment.persistence."/persist" = mkIf config.layers.layer-10.system.config.impermanence.enable {
      directories = [
        "/var/lib/caddy"
      ];
    };
  };
}
