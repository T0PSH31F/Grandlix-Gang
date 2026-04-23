{
  config,
  lib,
  inputs,
  ...
}:

{
  imports = [
    ./hardware.nix
    ./containers.nix
    ../../layers/20-services/22-ai/ai-services.nix
    ../../layers/20-services
    ../../layers/20-services/23-media
    ../../layers/30-identity/31-users/t0psh31f.nix
    inputs.impermanence.nixosModules.impermanence
    inputs.home-manager.nixosModules.home-manager
  ];

  # Stub missing option for flake-parts modules
  options.system-config.impermanence.enable = lib.mkEnableOption "Impermanence";

  config = {
    services-config.tailscale.enable = true;

    networking.hostName = "luffy";
    system.stateVersion = "25.05"; # Match your flake version

    nixpkgs.config.allowUnfree = true;

    # SOPS Secrets definition
    sops.age.keyFile = "/home/t0psh31f/.config/sops/age/keys.txt";
    sops.secrets."duckdns-token" = {
      sopsFile = lib.mkForce ../../layers/00-cyberia/03-treasure/secrets/duckdns.yaml;
      format = lib.mkForce "yaml";
    };
    sops.templates."duckdns-env".content = ''
      DUCKDNS_TOKEN=${config.sops.placeholder."duckdns-token"}
    '';
    sops.secrets."postgres-password" = {
      sopsFile = lib.mkForce ../../layers/00-cyberia/03-treasure/secrets/postgres.yaml;
      format = lib.mkForce "yaml";
    };

    # Podman Rootless Virtualization
    virtualisation.oci-containers.backend = "podman";
    virtualisation.podman = {
      enable = true;
      autoPrune.enable = true;
      dockerCompat = true;
    };

    # Headscale Server
    services.headscale-server.enable = true;

    # Native Postgres (Shared for Nextcloud, Immich, MaxKB etc.)
    services.postgresql = {
      enable = true;
      enableTCPIP = true;
      ensureUsers = [
        {
          name = "nextcloud";
          ensureDBOwnership = true;
        }
        {
          name = "immich";
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [
        "nextcloud"
        "immich"
      ];
    };

    # ACME Let's Encrypt Wildcard via DuckDNS
    security.acme = {
      acceptTerms = true;
      defaults.email = "admin@lovelain.duckdns.org";
      certs."lovelain.duckdns.org" = {
        domain = "*.lovelain.duckdns.org";
        extraDomainNames = [
          "lovelain.duckdns.org"
          "t0psh31f.duckdns.org"
          "nixfp.duckdns.org"
          "chat.lovelain.duckdns.org"
        ];
        dnsProvider = "duckdns";
        environmentFile = config.sops.templates."duckdns-env".path;
      };
    };

    # DuckDNS Auto-Updater using ddclient
    services.ddclient = {
      enable = true;
      domains = [
        "lovelain.duckdns.org"
        "t0psh31f.duckdns.org"
        "nixfp.duckdns.org"
        "chat.lovelain.duckdns.org"
      ];
      protocol = "duckdns";
      passwordFile = config.sops.secrets."duckdns-token".path;
    };

    # Enable Native Services from flake-parts
    services.nextcloud-server = {
      enable = true;
      hostName = "nextcloud.lovelain.duckdns.org";
    };
    # Prevent Nginx from conflicting with Caddy's 80/443 binding
    services.nginx.virtualHosts."nextcloud.lovelain.duckdns.org".listen = lib.mkForce [
      {
        addr = "127.0.0.1";
        port = 8080;
      }
    ];

    services.immich-server = {
      enable = true;
      port = 2283;
    };

    services.vaultwarden = {
      enable = true;
      config = {
        ROCKET_PORT = 8222;
        ROCKET_ADDRESS = "127.0.0.1";
      };
    };

    services-config.monitoring = {
      enable = false;
      domain = "grafana.lovelain.duckdns.org";
      grafana.port = 3001; # avoids homepage on 3000
      prometheus.port = 9090;
    };

    services-config.adguard = {
      enable = true;
      port = 3002; # avoids homepage and grafana
    };

    services.ai-services = {
      enable = true;
      qdrant.enable = true;
      ollama.enable = true;
    };

    # Caddy Reverse Proxy
    services.caddy = {
      enable = true;
      globalConfig = ''
        email admin@lovelain.duckdns.org
      '';
      virtualHosts."lovelain.duckdns.org" = {
        useACMEHost = "lovelain.duckdns.org";
        extraConfig = ''
          encode zstd gzip
          header Strict-Transport-Security "max-age=31536000; includeSubDomains"
          reverse_proxy localhost:3000
        '';
      };
      virtualHosts."*.lovelain.duckdns.org" = {
        useACMEHost = "lovelain.duckdns.org";
        extraConfig = ''
          encode zstd gzip
          header Strict-Transport-Security "max-age=31536000; includeSubDomains"

          @ollama host ollama.lovelain.duckdns.org
          handle @ollama { reverse_proxy localhost:11434 }

          @qdrant host qdrant.lovelain.duckdns.org
          handle @qdrant { reverse_proxy localhost:6333 }

          @crawl4ai host crawl4ai.lovelain.duckdns.org
          handle @crawl4ai { reverse_proxy localhost:32775 }

          @skyvernui host skyvern.lovelain.duckdns.org
          handle @skyvernui { reverse_proxy localhost:32776 }

          @skyvernapi host skyvernapi.lovelain.duckdns.org
          handle @skyvernapi { reverse_proxy localhost:32779 }

          @skyvernchrome host skyvernchrome.lovelain.duckdns.org
          handle @skyvernchrome { reverse_proxy localhost:32780 }

          @simstudio host simstudio.lovelain.duckdns.org
          handle @simstudio { reverse_proxy localhost:32790 }

          @simstudiort host simstudiort.lovelain.duckdns.org
          handle @simstudiort { reverse_proxy localhost:32789 }

          @maxkb host maxkb.lovelain.duckdns.org
          handle @maxkb { reverse_proxy localhost:32784 }

          @nextcloud host nextcloud.lovelain.duckdns.org
          handle @nextcloud { reverse_proxy localhost:8080 }

          @immich host immich.lovelain.duckdns.org
          handle @immich { reverse_proxy localhost:2283 }

          @spacedrive host spacedrive.lovelain.duckdns.org
          handle @spacedrive { reverse_proxy localhost:32768 }

          @spacedriveapi host spacedriveapi.lovelain.duckdns.org
          handle @spacedriveapi { reverse_proxy localhost:32769 }

          @vault host vault.lovelain.duckdns.org
          handle @vault { reverse_proxy localhost:8222 }

          @kavita host kavita.lovelain.duckdns.org
          handle @kavita { reverse_proxy localhost:5000 }

          @headscale host headscale.lovelain.duckdns.org
          handle @headscale { reverse_proxy localhost:8080 }

          @chat host chat.lovelain.duckdns.org
          handle @chat { reverse_proxy localhost:3004 }

          @beszel host beszel.lovelain.duckdns.org
          handle @beszel { reverse_proxy localhost:32772 }

          @adguard host adguard.lovelain.duckdns.org
          handle @adguard { reverse_proxy localhost:3002 }

          @openclaw host openclaw.lovelain.duckdns.org
          handle @openclaw { reverse_proxy localhost:59879 }
        '';
      };
    };

    # Firewall rules
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [
        80
        443
        22
      ];
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.t0psh31f.imports = [ inputs.niri.homeModules.config ];
    };
  };
}
