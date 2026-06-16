{
  config,
  lib,
  pkgs,
  ...
}:
{
  # ============================================================================
  # 00 - CORE IMPORTS
  # ============================================================================
  imports = [
    ./hardware.nix
    ./containers.nix

    ../../layers/10-system/13-users/t0psh31f.nix
  ];

  # ============================================================================
  # 01 - MACHINE IDENTITY
  # ============================================================================
  networking.hostName = "luffy";
  system.stateVersion = "25.05";

  nixpkgs.config.allowUnfree = true;

  # ============================================================================
  # 02 - BOOT & KERNEL (Systemd-Boot)
  # ============================================================================
  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = lib.mkForce null; # Do not prune old generations
    efi.canTouchEfiVariables = true;
    timeout = 5;
  };
  boot.kernelParams = [ "nvidia-drm.modeset=1" ];

  nix.gc.automatic = lib.mkForce false; # Do not run automatic GC/delete generations

  # ============================================================================
  # 02 - LAYERED FEATURE FLAGS (Overrides)
  # ============================================================================
  layers = {
    layer-10.system = {
      hardware.kernel = "cachyos"; # Maximum performance for desktop
      config.impermanence.enable = true;
      virtualization.enable = true;
      mobile.android.enable = true;
      peripherals.razer.enable = lib.mkForce false; # Disabled: openrazer driver incompatible with linux 7.0.10
    };
    layer-70.agent = {
      ai-agent-stack.enable = true;
    };
  };
  layers.layer-20.services.config.your-spotify.enable = true;

  # Switch to SDDM for stability and better NVIDIA support
  layers.layer-30.theming.themes.greeter = {
    sddm.enable = false;
    greetd.enable = true;
  };

  # xserver not needed with cage greeter

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
      enable = false; # Commented out/disabled to unblock rebuild
      port = 3002; # avoids homepage and grafana
      bindHosts = [
        "127.0.0.1"
        "192.168.1.53"
        "100.80.146.120"
      ];
    };
  };

  hardware.nvidia = {
    enable = true;
    modesetting.enable = true;
    package = lib.mkForce config.boot.kernelPackages.nvidiaPackages.legacy_580;
  };

  # ============================================================================
  # 03 - SERVICE SPECIFICS & OVERRIDES (Layer 20)
  # ============================================================================
  services = {
    # Disable SillyTavern Tag Default to completely disable it
    sillytavern.enable = lib.mkForce false;

    # Headscale Server
    headscale-server.enable = true;

    # Native Postgres (Shared for Nextcloud, Immich, MaxKB etc.)
    postgresql = {
      enableTCPIP = true;
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

    # Prevent Nginx from conflicting with Caddy's 80/443 binding and Open-WebUI's 8080 binding
    nginx = {
      defaultHTTPListenPort = 8084;
      virtualHosts = {
        "nextcloud.lovelain.duckdns.org".listen = lib.mkForce [
          {
            addr = "127.0.0.1";
            port = 8084;
          }
        ];
        # Unified vhost: Caddy reverse-proxies matrix/element to https://127.0.0.1:8443
        # Route by Host: matrix.local → matrix-synapse:8008, element.local → element-web
        "matrix.local" = {
          enableACME = lib.mkForce false;
          forceSSL = lib.mkForce false;
          onlySSL = lib.mkForce true;
          sslCertificate = "/var/lib/acme/matrix.local/fullchain.pem";
          sslCertificateKey = "/var/lib/acme/matrix.local/key.pem";
          listen = lib.mkForce [
            {
              addr = "127.0.0.1";
              port = 8443;
              ssl = true;
            }
          ];
          locations."/" = {
            proxyPass = "http://127.0.0.1:8008";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_read_timeout 600s;
            '';
          };
        };
        # Reuse the same vhost slot for element.local by adding serverName aliases
        "element.local" = {
          enableACME = lib.mkForce false;
          forceSSL = lib.mkForce false;
          onlySSL = lib.mkForce true;
          sslCertificate = "/var/lib/acme/element.local/fullchain.pem";
          sslCertificateKey = "/var/lib/acme/element.local/key.pem";
          listen = lib.mkForce [
            {
              addr = "127.0.0.1";
              port = 8444;
              ssl = true;
            }
          ];
          root = lib.mkForce "/var/www/element";
        };
        "searx.local".listen = lib.mkForce [
          {
            addr = "127.0.0.1";
            port = 8084;
          }
        ];
        "hermes-matrix.local" = {
          listen = lib.mkForce [
            {
              addr = "0.0.0.0";
              port = 8087;
              extraParameters = [ "default_server" ];
            }
          ];
          locations."/" = {
            proxyPass = "http://127.0.0.1:8008";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            '';
          };
        };
      };
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
      qdrant.enable = false; # Commented out/disabled to unblock rebuild
      ollama = {
        enable = true;
        acceleration = null;
      };
      chromadb.enable = true;
      open-webui.enable = true;
      sillytavern.enable = false; # Commented out/disabled to unblock rebuild
      jan.enable = true;
      lmstudio.enable = lib.mkForce false; # Disabled: packaging error in unstable
      aider.enable = true;
      postgresql.enable = true;
    };

    # Moved from Nami
    n8n-server.enable = true;
    komga-server.enable = true;
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
          handle @nextcloud { reverse_proxy localhost:8084 }


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
      virtualHosts."element.local" = {
        extraConfig = ''
          reverse_proxy https://127.0.0.1:8443 {
            transport http {
              tls_insecure_skip_verify
            }
          }
        '';
      };
      virtualHosts."matrix.local" = {
        extraConfig = ''
          reverse_proxy https://127.0.0.1:8443 {
            transport http {
              tls_insecure_skip_verify
            }
          }
        '';
      };
      # Public Matrix homeserver on duckdns domain
      virtualHosts."matrix.lovelain.duckdns.org" = {
        extraConfig = ''
          # Serve well-known discovery documents for phone clients
          @wellknownClient path /.well-known/matrix/client
          handle @wellknownClient {
            header Content-Type application/json
            respond `{"m.homeserver":{"base_url":"https://matrix.lovelain.duckdns.org"},"m.identity_server":{"base_url":"https://vector.im"}}` 200
          }
          @wellknownServer path /.well-known/matrix/server
          handle @wellknownServer {
            header Content-Type application/json
            respond `{"m.server":"matrix.lovelain.duckdns.org:443"}` 200
          }
          reverse_proxy https://127.0.0.1:8443 {
            transport http {
              tls_insecure_skip_verify
            }
          }
        '';
      };
      # Public Element Web client on duckdns domain
      virtualHosts."element.lovelain.duckdns.org" = {
        extraConfig = ''
          reverse_proxy https://127.0.0.1:8443 {
            transport http {
              tls_insecure_skip_verify
            }
          }
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
      8008 # Matrix Synapse direct access for hermes gateway
      8443 # Nginx SSL proxy for Matrix/Element (bypass Caddy TLS issues)
      8087 # Nginx HTTP proxy for Matrix (no SSL, for hermes gateway)
    ];
  };

  services.ollama.package = lib.mkForce pkgs.ollama;



  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
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
    defaults.email = lib.mkForce "admin@lovelain.duckdns.org";
    # Cert only on the wildcard - Caddy handles the public vhosts
    # ACME extraDomainNames would create nginx vhosts on port 443 conflicting with Caddy
    certs."lovelain.duckdns.org" = {
      domain = "*.lovelain.duckdns.org";
      dnsProvider = "duckdns";
      environmentFile = config.sops.templates."duckdns-env".path;
    };
  };
}
