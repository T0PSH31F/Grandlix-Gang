# Homepage Dashboard
# Documentation: https://gethomepage.dev
# Service Widgets (Plugin Catalog): https://gethomepage.dev/latest/widgets/services/
# Customization: https://gethomepage.dev/latest/configs/settings/
# layers/nixos/services/homepage-dashboard.nix
{
  config,
  lib,
  ...
}:

with lib;
let
  cfg = config.features.services.config.homepage-dashboard;

  # Safe port getter with fallback
  getServicePort =
    service: default:
    if hasAttr service config.services && hasAttr "port" config.services.${service} then
      toString config.services.${service}.port
    else
      toString default;

  # Check if service is enabled - with additional safety
  isServiceEnabled =
    service:
    (hasAttr service config.services)
    && (hasAttr "enable" config.services.${service})
    && (config.services.${service}.enable == true);

  # Safe pathExists wrapper to prevent evaluation errors
  safePathExists = path: builtins.pathExists path || false;
in
{
  options.features.services.config.homepage-dashboard = {
    enable = mkEnableOption "Homepage Dashboard";

    port = mkOption {
      type = types.port;
      default = 8082;
      description = "Port to expose Homepage Dashboard on";
    };

    noctalia = {
      enable = mkEnableOption "Noctalia theme integration";

      templatePath = mkOption {
        type = types.str;
        default = "/etc/homepage-dashboard/noctalia-theme.yaml";
        description = "Path to Noctalia-generated theme configuration";
      };
    };

    domain = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Domain name for the dashboard (for reverse proxy)";
    };
    lovable = {
      enable = mkEnableOption "Lovable (One Piece / Cyberpunk) theme";
      cssPath = mkOption {
        type = types.path;
        default = ../../../layers/00-cyberia/02-assets/templates/homepage-theme.css;
        description = "Path to Lovable CSS theme";
      };
      jsPath = mkOption {
        type = types.path;
        default = ../../../layers/00-cyberia/02-assets/templates/homepage-theme.js;
        description = "Path to Lovable JS effects";
      };
    };
  };

  options.clan.services.desktop.homepage-dashboard = {
    enable = mkEnableOption "Homepage Dashboard Clan Service";
  };
  
  config = mkIf (cfg.enable || config.clan.services.desktop.homepage-dashboard.enable) {
    services.homepage-dashboard = {
      enable = true;
      listenPort = cfg.port;

      settings = mkMerge [
        {
          title = "Nix Flake Pirates Dashboard";
          favicon = "https://raw.githubusercontent.com/gethomepage/homepage/main/public/homepage.png";

          # Base theme
          theme = "dark";
          color = "slate";

          layout = {
            "Media Services" = {
              style = "row";
              columns = 4;
              icon = "mdi-multimedia";
            };
            "Monitoring" = {
              style = "row";
              columns = 3;
              icon = "mdi-chart-line";
            };
            "AI & Automation" = {
              style = "row";
              columns = 4;
              icon = "mdi-robot";
            };
            "Infrastructure" = {
              style = "row";
              columns = 4;
              icon = "mdi-server";
            };
          };

          headerStyle = "boxed";
          cardBlur = "sm";
          hideVersion = true;
        }

        # Noctalia theme override (only if Lovable NOT enabled)
        (mkIf (cfg.noctalia.enable && !cfg.lovable.enable) {
          # Theme colors will be injected via custom CSS
          # customCss = builtins.readFile cfg.noctalia.templatePath;
        })

        # Lovable theme override
        (mkIf cfg.lovable.enable {
          customCss = builtins.readFile cfg.lovable.cssPath;
          customJS = builtins.readFile cfg.lovable.jsPath;
          background = {
            image = "https://images.unsplash.com/photo-1451187580459-43490279c0fa?q=80&w=2672&auto=format&fit=crop"; # Deep space fallback
            opacity = 0.2;
          };
        })
      ];

      widgets = [
        {
          search = {
            provider = "duckduckgo";
            target = "_blank";
            showSearchSuggestions = true;
            focus = true;
          };
        }
        {
          resources = {
            cpu = true;
            memory = true;
            disk = "/";
            uptime = true;
          };
        }
        {
          datetime = {
            text_size = "xl";
            format = {
              dateStyle = "long";
              timeStyle = "short";
              hour12 = false;
            };
          };
        }
      ];

      services = [
        {
          "Media Services" = flatten [
            (optional (isServiceEnabled "jellyfin") {
              "Jellyfin" = {
                icon = "jellyfin.png"; # Manually map if needed, but keeping standard for now
                href = "http://localhost:8096";
                description = "Media Server";
                widget = {
                  type = "jellyfin";
                  url = "http://localhost:8096";
                  key = "{{HOMEPAGE_VAR_JELLYFIN_KEY}}";
                };
              };
            })
            (optional (isServiceEnabled "calibre-web-app") {
              "Calibre-Web" = {
                icon = "calibre-web.png";
                href = "http://localhost:${getServicePort "calibre-web-app" 8083}";
                description = "E-Book Library";
              };
            })
            (optional (isServiceEnabled "sonarr") {
              "Sonarr" = {
                icon = "sonarr.png";
                href = "http://localhost:8989";
                description = "TV Series Management";
                widget = {
                  type = "sonarr";
                  url = "http://localhost:8989";
                  key = "{{HOMEPAGE_VAR_SONARR_KEY}}";
                };
              };
            })
            (optional (isServiceEnabled "radarr") {
              "Radarr" = {
                icon = "radarr.png";
                href = "http://localhost:7878";
                description = "Movie Management";
                widget = {
                  type = "radarr";
                  url = "http://localhost:7878";
                  key = "{{HOMEPAGE_VAR_RADARR_KEY}}";
                };
              };
            })
            (optional (isServiceEnabled "prowlarr") {
              "Prowlarr" = {
                icon = "prowlarr.png";
                href = "http://localhost:9696";
                description = "Indexer Manager";
                widget = {
                  type = "prowlarr";
                  url = "http://localhost:9696";
                  key = "{{HOMEPAGE_VAR_PROWLARR_KEY}}";
                };
              };
            })
            (optional (isServiceEnabled "bazarr") {
              "Bazarr" = {
                icon = "bazarr.png";
                href = "http://localhost:6767";
                description = "Subtitle Management";
                widget = {
                  type = "bazarr";
                  url = "http://localhost:6767";
                  key = "{{HOMEPAGE_VAR_BAZARR_KEY}}";
                };
              };
            })
            (optional (isServiceEnabled "deluge-server") {
              "Deluge" = {
                icon = "deluge.png";
                href = "http://localhost:${getServicePort "deluge-server" 8113}";
                description = "Torrent Client";
                widget = {
                  type = "deluge";
                  url = "http://localhost:${getServicePort "deluge-server" 8113}";
                  password = "{{HOMEPAGE_VAR_DELUGE_PASSWORD}}";
                };
              };
            })
            (optional (isServiceEnabled "transmission-server") {
              "Transmission" = {
                icon = "transmission.png";
                href = "http://localhost:${getServicePort "transmission-server" 9091}";
                description = "Torrent Client";
                widget = {
                  type = "transmission";
                  url = "http://localhost:${getServicePort "transmission-server" 9091}";
                  username = "{{HOMEPAGE_VAR_TRANSMISSION_USERNAME}}";
                  password = "{{HOMEPAGE_VAR_TRANSMISSION_PASSWORD}}";
                };
              };
            })
            (optional (isServiceEnabled "komga") {
              "Komga" = {
                icon = "komga.png";
                href = "http://localhost:25600";
                description = "Comic/Manga Server";
                widget = {
                  type = "komga";
                  url = "http://localhost:25600";
                  username = "{{HOMEPAGE_VAR_KOMGA_USERNAME}}";
                  password = "{{HOMEPAGE_VAR_KOMGA_PASSWORD}}";
                };
              };
            })
            (optional (isServiceEnabled "your-spotify") {
              "Your Spotify" = {
                icon = "spotify.png";
                href = "http://localhost:3457";
                description = "Spotify Analytics";
              };
            })
          ];
        }
        {
          "Monitoring" = flatten [
            (optional (isServiceEnabled "glances-server") {
              "Glances" = {
                icon = "glances.png";
                href = "http://127.0.0.1:${getServicePort "glances-server" 61208}";
                description = "System Monitoring";
                widget = {
                  type = "glances";
                  url = "http://127.0.0.1:${getServicePort "glances-server" 61208}";
                  version = 4;
                };
              };
            })
            (optional (isServiceEnabled "grafana") {
              "Grafana" = {
                icon = "grafana.png";
                href = "http://localhost:${getServicePort "grafana" 3000}";
                description = "Metrics & Dashboards";
              };
            })
            (optional (isServiceEnabled "prometheus") {
              "Prometheus" = {
                icon = "prometheus.png";
                href = "http://localhost:${getServicePort "prometheus" 9090}";
                description = "Metrics Collection";
              };
            })
            (optional (isServiceEnabled "loki") {
              "Loki" = {
                icon = "loki.png";
                href = "http://localhost:3100";
                description = "Log Aggregation";
              };
            })
            (optional (isServiceEnabled "adguardhome") {
              "AdGuard Home" = {
                icon = "adguard-home.png";
                href = "http://localhost:3000";
                description = "DNS Filtering";
                widget = {
                  type = "adguard";
                  url = "http://localhost:3000";
                  username = "{{HOMEPAGE_VAR_ADGUARD_USERNAME}}";
                  password = "{{HOMEPAGE_VAR_ADGUARD_PASSWORD}}";
                };
              };
            })
          ];
        }
        {
          "AI & Automation" = [
            {
              "Open WebUI" = {
                icon = "openai.png";
                href = "http://localhost:8080";
                description = "LLM Interface";
                # Native NixOS service - no container reference
              };
            }
            {
              "NextJS Ollama UI" = {
                icon = "openai.png";
                href = "http://localhost:3001";
                description = "NextJS LLM UI";
              };
            }
            {
              "SillyTavern" = {
                icon = "mdi-chat";
                href = "http://localhost:8000";
                description = "Character AI Chat";
                # Native NixOS service - no container reference
              };
            }
            {
              "n8n" = {
                icon = "n8n.png";
                href = "http://localhost:5678";
                description = "Workflow Automation";
              };
            }
            {
              "Qdrant" = {
                icon = "qdrant.png";
                href = "http://localhost:6333/dashboard";
                description = "Vector Database";
                # Native NixOS service - no container reference
              };
            }
            {
              "Karakeep" = {
                icon = "mdi-bookmark-multiple";
                href = "http://localhost:3000";
                description = "Bookmark Manager";
                # Native NixOS service - no container reference
              };
            }
          ];
        }
        {
          "Infrastructure" = flatten [
            (optional (isServiceEnabled "filebrowser-app") {
              "FileBrowser" = {
                icon = "filebrowser.png";
                href = "http://localhost:${getServicePort "filebrowser-app" 8085}";
                description = "Web File Manager";
              };
            })
            (optional (isServiceEnabled "nextcloud") {
              "Nextcloud" = {
                icon = "nextcloud.png";
                href = "https://${config.services.nextcloud-server.hostName}";
                description = "Cloud Storage";
                widget = {
                  type = "nextcloud";
                  url = "https://${config.services.nextcloud-server.hostName}";
                  username = "{{HOMEPAGE_VAR_NEXTCLOUD_USERNAME}}";
                  password = "{{HOMEPAGE_VAR_NEXTCLOUD_PASSWORD}}";
                };
              };
            })
            (optional (isServiceEnabled "home-assistant-server") {
              "Home Assistant" = {
                icon = "home-assistant.png";
                href = "http://localhost:${getServicePort "home-assistant-server" 8123}";
                description = "Home Automation";
                widget = {
                  type = "homeassistant";
                  url = "http://localhost:${getServicePort "home-assistant-server" 8123}";
                  key = "{{HOMEPAGE_VAR_HASS_KEY}}";
                };
              };
            })
            (optional (isServiceEnabled "headscale-server") {
              "Headscale" = {
                icon = "headscale.png";
                href = "http://localhost:${getServicePort "headscale-server" 8086}/web";
                description = "Tailscale Control Server";
              };
            })
            (optional (isServiceEnabled "searxng") {
              "SearXNG" = {
                icon = "searxng.png";
                href = "http://localhost:${getServicePort "searxng" 8888}";
                description = "Meta Search Engine";
              };
            })
            (optional (isServiceEnabled "immich") {
              "Immich" = {
                icon = "immich.png";
                href = "http://localhost:2283";
                description = "Photo Management";
                widget = {
                  type = "immich";
                  url = "http://localhost:2283";
                  key = "{{HOMEPAGE_VAR_IMMICH_KEY}}";
                  version = 2;
                };
              };
            })
            {
              "Portainer" = {
                icon = "portainer.png";
                href = "http://localhost:9000";
                description = "Container Management";
              };
            }
            (optional (isServiceEnabled "matrix-synapse") {
              "Matrix Synapse" = {
                icon = "matrix.png";
                href = "http://localhost:8008";
                description = "Federated Chat";
              };
            })
            (optional (isServiceEnabled "mautrix-bridges") {
              "Mautrix Bridges" = {
                icon = "matrix.png";
                href = "http://localhost:8008/_matrix/static/";
                description = "Matrix Bridges Status";
              };
            })
            {
              "Caddy" = {
                icon = "caddy.png";
                href = "http://localhost:2019";
                description = "Web Server";
              };
            }
          ];
        }
      ];
    };

    # Firewall configuration
    networking.firewall.allowedTCPPorts = [ cfg.port ];

    # User/Group with proper permissions
    users.users.homepage-dashboard = {
      isSystemUser = true;
      group = "homepage-dashboard";
      extraGroups = [ "podman" ];
    };
    users.groups.homepage-dashboard = { };

    # Impermanence support
    environment.persistence."/persist" = mkIf config.features.system.config.impermanence.enable {
      directories = [
        {
          directory = "/var/lib/homepage-dashboard";
          user = "homepage-dashboard";
          group = "homepage-dashboard";
          mode = "0700";
        }
      ];
    };

    # Fix StateDirectory conflict with impermanence
    systemd.services.homepage-dashboard = {
      serviceConfig = {
        StateDirectory = mkForce [ ];
        ReadWritePaths = [ "/var/lib/homepage-dashboard" ];
        Restart = "on-failure";
        RestartSec = "5s";
      };

      # Ensure Podman socket access
      after = [
        "podman.socket"
        "network-online.target"
      ];
      wants = [ "network-online.target" ];
      requires = mkIf config.virtualisation.podman.enable [ "podman.socket" ];
    };

    # Tmpfiles rules for directory creation
    systemd.tmpfiles.rules = [
      "d /var/lib/homepage-dashboard 0700 homepage-dashboard homepage-dashboard -"
    ]
    ++ optional config.features.system.config.impermanence.enable "d /persist/var/lib/homepage-dashboard 0700 homepage-dashboard homepage-dashboard -";
  };
}
