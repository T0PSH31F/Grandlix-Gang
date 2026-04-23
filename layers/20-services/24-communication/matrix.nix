{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.services.matrix-server = {
    enable = mkEnableOption "Matrix Synapse homeserver";

    serverName = mkOption {
      type = types.str;
      default = "matrix.local";
      description = "The domain name of the Matrix homeserver";
    };

    useACME = mkOption {
      type = types.bool;
      default = false;
      description = "Use Let's Encrypt ACME certificates. Disable for .local domains.";
    };

    port = mkOption {
      type = types.int;
      default = 8008;
      description = "Port for Matrix Synapse";
    };

    enableRegistration = mkOption {
      type = types.bool;
      default = false;
      description = "Allow new user registration";
    };

    enableMetrics = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Prometheus metrics";
    };

    maxUploadSize = mkOption {
      type = types.str;
      default = "50M";
      description = "Maximum upload size for media";
    };
  };

  config = mkIf config.services.matrix-server.enable {
    # Workaround: clan-core's clanServices/matrix-synapse/nginx.nix sets
    # sslDhparam = config.security.dhparams.params.nginx.path which creates
    # an infinite recursion with the updated nixpkgs nginx module (which does
    # `mkIf (cfg.sslDhparam == true)` causing evaluation before merge).
    # We break the cycle by force-setting sslDhparam and disabling dhparams.
    services.nginx.sslDhparam = lib.mkForce null;
    security.dhparams.enable = lib.mkForce false;

    services.matrix-synapse = {
      enable = true;

      settings = {
        server_name = lib.mkDefault config.services.matrix-server.serverName;

        listeners = [
          {
            port = config.services.matrix-server.port;
            bind_addresses = [
              "::1"
              "127.0.0.1"
            ];
            type = "http";
            tls = false;
            x_forwarded = true;
            resources = [
              {
                names = [
                  "client"
                  "federation"
                ];
                compress = false;
              }
            ];
          }
        ]
        ++ optional config.services.matrix-server.enableMetrics {
          port = 9000;
          bind_addresses = [ "127.0.0.1" ];
          type = "http";
          tls = false;
          resources = [
            {
              names = [ "metrics" ];
              compress = false;
            }
          ];
        };

        # Database configuration
        database = {
          name = "psycopg2";
          args = {
            user = "matrix-synapse";
            database = "matrix-synapse";
            cp_min = 5;
            cp_max = 10;
          };
        };

        # Registration
        enable_registration = config.services.matrix-server.enableRegistration;
        registration_shared_secret_path = lib.mkForce "/var/lib/matrix-synapse/registration_shared_secret";

        # Media
        max_upload_size = config.services.matrix-server.maxUploadSize;
        url_preview_enabled = true;
        url_preview_ip_range_blacklist = [
          "127.0.0.0/8"
          "10.0.0.0/8"
          "172.16.0.0/12"
          "192.168.0.0/16"
          "100.64.0.0/10"
          "169.254.0.0/16"
          "::1/128"
          "fe80::/64"
          "fc00::/7"
        ];

        # Performance
        enable_metrics = config.services.matrix-server.enableMetrics;

        # Federation
        federation_domain_whitelist = null; # Allow federation with all servers

        # Presence
        presence.enabled = true;
      };

      # Extra configuration
      extraConfigFiles = [
        # Add path to signing key if needed
      ];
    };

    # PostgreSQL database for Matrix
    services.postgresql = {
      enable = true;
      ensureDatabases = [ "matrix-synapse" ];
      ensureUsers = [
        {
          name = "matrix-synapse";
          ensureDBOwnership = true;
        }
      ];

      # Optimize for Matrix
      settings = {
        shared_buffers = "256MB";
        effective_cache_size = "1GB";
      };
    };

    # Nginx reverse proxy (optional but recommended)
    services.nginx.virtualHosts.${config.services.matrix-server.serverName} =
      mkIf config.services.nginx.enable
        {
          # Only use ACME for non-.local domains
          enableACME = config.services.matrix-server.useACME;
          # Use self-signed cert for .local domains when ACME is disabled
          sslCertificate = mkIf (
            !config.services.matrix-server.useACME
          ) "/var/lib/nginx/matrix-synapse-certs/cert.pem";
          sslCertificateKey = mkIf (
            !config.services.matrix-server.useACME
          ) "/var/lib/nginx/matrix-synapse-certs/key.pem";
          forceSSL = config.services.matrix-server.useACME;
          # For local domains, allow both HTTP and HTTPS
          addSSL = !config.services.matrix-server.useACME;

          locations."/_matrix" = {
            proxyPass = "http://[::1]:${toString config.services.matrix-server.port}";
            extraConfig = ''
              proxy_set_header X-Forwarded-For $remote_addr;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_set_header Host $host;
              client_max_body_size ${config.services.matrix-server.maxUploadSize};
            '';
          };

          locations."/_synapse/client" = {
            proxyPass = "http://[::1]:${toString config.services.matrix-server.port}";
          };
        };

    # Generate self-signed certificate for .local domains
    systemd.services.matrix-synapse-ssl-init =
      mkIf (!config.services.matrix-server.useACME && config.services.nginx.enable)
        {
          description = "Generate self-signed SSL certificate for Matrix Synapse";
          wantedBy = [ "multi-user.target" ];
          before = [
            "nginx.service"
            "matrix-synapse.service"
          ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          script = ''
            SSL_DIR="/var/lib/matrix-synapse/ssl"
            NGINX_SSL_DIR="/var/lib/nginx/matrix-synapse-certs"

            if [ ! -f "$SSL_DIR/cert.pem" ]; then
              mkdir -p "$SSL_DIR"
              ${pkgs.openssl}/bin/openssl req -x509 -newkey rsa:4096 \
                -keyout "$SSL_DIR/key.pem" \
                -out "$SSL_DIR/cert.pem" \
                -days 365 -nodes \
                -subj "/CN=${config.services.matrix-server.serverName}"
              chown -R matrix-synapse:matrix-synapse "$SSL_DIR"
              chmod 600 "$SSL_DIR/key.pem"
              chmod 644 "$SSL_DIR/cert.pem"
            fi

            # Copy certs for Nginx access to avoid permission issues
            mkdir -p "$NGINX_SSL_DIR"
            cp "$SSL_DIR/cert.pem" "$NGINX_SSL_DIR/cert.pem"
            cp "$SSL_DIR/key.pem" "$NGINX_SSL_DIR/key.pem"
            chown -R nginx:nginx "$NGINX_SSL_DIR"
            chmod 700 "$NGINX_SSL_DIR"
            chmod 600 "$NGINX_SSL_DIR/key.pem"
            chmod 644 "$NGINX_SSL_DIR/cert.pem"
          '';
        };

    # Firewall
    networking.firewall.allowedTCPPorts = [
      config.services.matrix-server.port
      8448 # Federation port
    ];

    # Allow Nginx to read certificates
    users.users.nginx.extraGroups = [ "matrix-synapse" ];
    systemd.tmpfiles.rules = [
      "z /var/lib/matrix-synapse 0750 matrix-synapse matrix-synapse -"
      "z /var/lib/matrix-synapse/ssl 0750 matrix-synapse matrix-synapse -"
      # Grant nginx explicit read access via ACL
      "a /var/lib/matrix-synapse - - - - u:nginx:--x"
      "a /var/lib/matrix-synapse/ssl - - - - u:nginx:r-x"
      "a /var/lib/matrix-synapse/ssl/cert.pem - - - - u:nginx:r--"
      "a /var/lib/matrix-synapse/ssl/key.pem - - - - u:nginx:r--"
    ];
    systemd.services.matrix-synapse.serviceConfig.StateDirectoryMode = "0750";

    # Ensure data is persisted

    environment.persistence."/persist" = mkIf config.system-config.impermanence.enable {

      directories = [

        "/var/lib/matrix-synapse"
      ];

    };

  };
}
