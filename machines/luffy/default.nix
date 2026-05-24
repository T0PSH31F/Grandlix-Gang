{
  config,
  lib,
  ...
}:
{
  # ============================================================================
  # 00 - CORE IMPORTS
  # ============================================================================
  imports = [
    ./hardware.nix
    ./disko.nix
    ./containers.nix

    ../../layers/10-system/13-users/t0psh31f.nix
  ];

  # ============================================================================
  # 01 - MACHINE IDENTITY
  # ============================================================================
  networking.hostName = "luffy";
  system.stateVersion = "25.05";

  # ----------------------------------------------------------------------------
  # AVAILABLE PROFILES / TAGS
  # ----------------------------------------------------------------------------
  # Tags define the machine's role and automatically enable corresponding features.
  # See `layers/90-profiles/tags/` for explicit definitions.
  #
  # Hardware/Form Factor:
  #   "workstation" : Enables base limits, themes, and network tools (avahi, tailscale, ssh).
  #   "desktop"     : Enables graphical hardware features (bluetooth), automount, portals, flatpak.
  #   "laptop"      : Enables battery optimizations and wireless tools.
  #
  # Roles:
  #   "server"      : Enables server base infra (monitoring, tailscale, adguard).
  #   "development" : Enables coding tools, Python, VSCode, and dev agents (Opencode, Antigravity).
  #   "gaming"      : Enables Steam, GameMode, Lutris, emulators, etc.
  #   "ai-server"   : Enables local AI backend (llms, sillytavern, wyoming, ai-services, dashboard).
  #   "homelab"     : Enables home infra (home-assistant, searxng, headscale, vaultwarden, etc).
  #   "cache-server": Enables Harmonia Nix binary cache.
  #   "media-server": Enables the *arr stack, Jellyfin, Deluge, etc.
  # ----------------------------------------------------------------------------

  nixpkgs.config.allowUnfree = true;

  # ============================================================================
  # 02 - LAYERED FEATURE FLAGS (Overrides)
  # ============================================================================
  layers = {
    layer-10.system = {
      config.impermanence.enable = true;
      virtualization.enable = true;
    };
    layer-70.agent = {
      ai-agent-stack.enable = true;
    };
  };
  layers.layer-20.services.config.your-spotify.enable = true;

  layers.layer-30.theming.themes.greeter = {
    sddm.enable = true;
    greetd.enable = false;
  };

  # SDDM uses X11 by default in this config, which is safer for many setups
  services.xserver.enable = true;

  layers.layer-40.desktop = {
    hyprland.enable = true;
    noctalia.backend = "hyprland";
  };

  layers.layer-20.services.config = {
    monitoring = {
      enable = false;
      domain = "grafana.lovelain.duckdns.org";
      grafana.port = 3001; # avoids homepage on 3000
      prometheus.port = 9090;
    };
    adguard = {
      enable = true;
      port = 3002; # avoids homepage and grafana
      bindHosts = [ "127.0.0.1" "192.168.1.53" "100.80.146.120" ];
    };
  };

  hardware.nvidia = {
    enable = true;
    package = lib.mkForce config.boot.kernelPackages.nvidiaPackages.legacy_580;
  };

  # ============================================================================
  # 03 - SERVICE SPECIFICS & OVERRIDES (Layer 20)
  # ============================================================================
  services = {
    # Headscale Server
    headscale-server.enable = true;

    # Native Postgres (Shared for Nextcloud, Immich, MaxKB etc.)
    postgresql = {
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

    # DuckDNS Auto-Updater using ddclient
    ddclient = {
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
    nextcloud-server = {
      enable = true;
      hostName = "nextcloud.lovelain.duckdns.org";
    };

    # Prevent Nginx from conflicting with Caddy's 80/443 binding
    nginx = {
      defaultHTTPListenPort = 8080;
      virtualHosts."nextcloud.lovelain.duckdns.org".listen = lib.mkForce [
        {
          addr = "127.0.0.1";
          port = 8080;
        }
      ];
    };

    immich-server = {
      enable = false;
      port = 2283;
    };

    vaultwarden = {
      enable = true;
      config = {
        ROCKET_PORT = 8222;
        ROCKET_ADDRESS = lib.mkForce "127.0.0.1";
      };
    };

    ai-services = {
      enable = true;
      qdrant.enable = true;
      ollama = {
        enable = true;
        acceleration = "cuda";
      };
      chromadb.enable = true;
      open-webui.enable = true;
      sillytavern.enable = true;
      jan.enable = true;
      aider.enable = true;
      cherry-studio.enable = true;
      postgresql.enable = true;
    };

    # Moved from Nami
    n8n-server.enable = true;
    komga-server.enable = true;
    matrix-server = {
      enable = true;
      serverName = "matrix.local";
    };
    mautrix-bridges = {
      enable = true;
      homeserverUrl = "http://localhost:8008";
      homeserverDomain = "matrix.local";
      whatsapp.enable = true;
      signal.enable = true;
    };

    # Caddy Reverse Proxy
    caddy = {
      enable = true;
      globalConfig = ''
        email admin@lovelain.duckdns.org
      '';
      virtualHosts."lovelain.duckdns.org" = {
        useACMEHost = "lovelain.duckdns.org";
        extraConfig = ''
          encode zstd gzip
          header Strict-Transport-Security "max-age=31536000; includeSubDomains"
          reverse_proxy localhost:3006
        '';
      };
      virtualHosts."*.lovelain.duckdns.org" = {
        useACMEHost = "lovelain.duckdns.org";
        extraConfig = ''
          encode zstd gzip
          header Strict-Transport-Security "max-age=31536000; includeSubDomains"

          # ollama and qdrant moved to registry


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
          handle @headscale { reverse_proxy localhost:8086 }

          @chat host chat.lovelain.duckdns.org
          handle @chat { reverse_proxy localhost:3004 }

          @beszel host beszel.lovelain.duckdns.org
          handle @beszel { reverse_proxy localhost:32772 }

          @adguard host adguard.lovelain.duckdns.org
          handle @adguard { reverse_proxy localhost:3002 }

          @openclaw host openclaw.lovelain.duckdns.org
          handle @openclaw { reverse_proxy localhost:59879 }

          @n8n host n8n.lovelain.duckdns.org
          handle @n8n { reverse_proxy localhost:5678 }

          @komga host komga.lovelain.duckdns.org
          handle @komga { reverse_proxy localhost:25600 }

          @spotify host spotify.lovelain.duckdns.org
          handle @spotify { reverse_proxy localhost:3457 }
        '';
      };
    };
  };

  layers.layer-20.services.config.reverseProxy.routes = {
    ollama = 11434;
    qdrant = 6333;
  };

  # ============================================================================
  # 04 - SYSTEM & PROGRAM OVERRIDES
  # ============================================================================
  # Podman Rootless Virtualization
  virtualisation.oci-containers.backend = "podman";
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
    dockerCompat = true;
  };

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
    # users.t0psh31f.imports = [ inputs.niri.homeModules.config ];
  };

  # ============================================================================
  # 05 - SECURITY & SECRETS (SOPS/ACME)
  # ============================================================================
  sops.age.keyFile = "/persist/home/t0psh31f/.config/sops/age/keys.txt";
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
        "n8n.lovelain.duckdns.org"
        "komga.lovelain.duckdns.org"
        "spotify.lovelain.duckdns.org"
      ];
      dnsProvider = "duckdns";
      environmentFile = config.sops.templates."duckdns-env".path;
    };
  };
}
