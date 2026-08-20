{ config, lib, ... }:

with lib;

let
  cfg = config.layers.layer-20.services.config.homepage-dashboard;
  hostName = config.networking.hostName or "unknown";

  # Custom CSS for gradient effects — works on both machines
  gradientCSS = ''
    .greeting-text {
      background: linear-gradient(135deg, #667eea, #764ba2, #f093fb);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
      font-weight: bold;
    }
    .datetime-widget [class*="text-xl"] {
      background: linear-gradient(135deg, #667eea, #764ba2);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
    }
  '';

  # ---------------------------------------------------------------------------
  # Address constants — Tailscale IPs for cross-machine access
  # (LAN IPs don't work: luffy on Ethernet can't initiate to z0r0 on WiFi)
  # ---------------------------------------------------------------------------
  z0r0 = "100.87.170.11";
  luffy = "100.72.46.75";

  # The "other" machine — for glances remote stats widget
  remoteMachine = if hostName == "z0r0" then "luffy" else "z0r0";
  remoteIP = if hostName == "z0r0" then luffy else z0r0;

  ports = {
    # z0r0
    prometheus = 9090;
    loki = 3100;
    grafana = 3008;
    adguard = 3002;
    sillytavern = 8000;
    langfuse = 3005;
    brainService = 8010;
    llamaCpp = 8081;
    signalCli = 8080;
    hermesWorkspace = 3000;
    hermesDashboard = 9119;
    hermesWebui = 8788;
    aionUi = 3006;
    paperclip = 3101;
    missionControl = 3099;
    glances = 61208;

    # luffy — media
    jellyfin = 8096;
    sonarr = 8989;
    radarr = 7878;
    lidarr = 8686;
    readarr = 8787;
    prowlarr = 9696;
    bazarr = 6767;
    qbittorrent = 8095;
    aria2 = 6800;
    calibreWeb = 8093;
    yourSpotify = 3457;
    kavita = 5050;
    komga = 25600;

    # luffy — ai
    ollama = 11434;
    openWebui = 8088;
    chromadb = 8004;
    jan = 1337;
    maxkb = 32784;
    simStudio = 32790;
    qdrant = 6333;
    postgres = 5432;

    # luffy — infra
    vaultwarden = 8222;
    headscale = 8086;
    searxng = 8888;
    filebrowser = 8089;
    spacedrive = 32768;
    karakeep = 3007;

    # luffy — comms
    matrixSynapse = 8008;
    elementWeb = 8444;
    mautrixWhatsapp = 29317;
    mautrixSignal = 29318;
    rustdeskSignal = 21116;

    # luffy — automation
    n8n = 5678;
    homeAssistant = 8123;
    crawl4ai = 32775;
    skyvernUi = 32776;
    skyvernApi = 32779;

    # luffy — reverse proxy
    caddyAdmin = 2019;

    # luffy — new services
    opencompany = 5680;

    # z0r0 — AI routers
    kongGateway = 8090;
    freellmpool = 8082;
    freellmapi = 3003;
    mistralMcp = 3333;
    extremeRouter = 20128;
    omniroute = 20128; # Same port — only one active at a time
  };

  hostOf =
    machine:
    if machine == hostName then
      "127.0.0.1"
    else if machine == "z0r0" then
      z0r0
    else
      luffy;

  mkService =
    name:
    {
      machine,
      serviceName ? name,
      port,
      icon,
      description,
      widget ? null,
      siteMonitor ? null,
    }:
    let
      host = hostOf machine;
      href = "http://${host}:${toString port}";
    in
    {
      ${serviceName} = {
        inherit icon description;
        href = href;
        siteMonitor = if siteMonitor != null then siteMonitor else href;
      }
      // optionalAttrs (widget != null) { inherit widget; };
    };

  zSrv =
    n: p: ic: desc:
    mkService n {
      machine = "z0r0";
      port = ports.${p};
      icon = ic;
      description = "${desc} @z0r0";
    };
  lSrv =
    n: p: ic: desc:
    mkService n {
      machine = "luffy";
      port = ports.${p};
      icon = ic;
      description = "${desc} @luffy";
    };

  zSrvW =
    n: p: ic: desc: widget:
    mkService n {
      machine = "z0r0";
      port = ports.${p};
      icon = ic;
      description = "${desc} @z0r0";
      inherit widget;
    };
  lSrvW =
    n: p: ic: desc: widget:
    mkService n {
      machine = "luffy";
      port = ports.${p};
      icon = ic;
      description = "${desc} @luffy";
      inherit widget;
    };

  # ---------------------------------------------------------------------------
  # Service groups  —  Observability at top, then AI, Infra, Comms, Media, Auto
  # Icons: use si- (Simple Icons), mdi- (Material Design), or dashboard-icons names
  # ---------------------------------------------------------------------------
  groups = {
    Observability = [
      (zSrvW "Prometheus" "prometheus" "prometheus.png" "Metrics Collection" {
        type = "prometheus";
        url = "http://${hostOf "z0r0"}:${toString ports.prometheus}";
      })
      (zSrv "Loki" "loki" "loki.png" "Log Aggregation")
      (zSrvW "Grafana" "grafana" "grafana.png" "Dashboards & Visualization" {
        type = "grafana";
        url = "http://${hostOf "z0r0"}:${toString ports.grafana}";
        username = "admin";
        password = "admin";
      })
      (zSrvW "AdGuard Home" "adguard" "adguard-home.png" "DNS Filtering" {
        type = "adguard";
        url = "http://${hostOf "z0r0"}:${toString ports.adguard}";
        username = "admin";
        password = "admin";
      })
    ];

    "AI / Agents" = [
      (lSrv "Ollama" "ollama" "ollama.png" "LLM Inference Server")
      (lSrv "Open WebUI" "openWebui" "open-webui.png" "Chat Frontend")
      (lSrv "ChromaDB" "chromadb" "si-chromadb" "Vector Database")
      (lSrv "Qdrant" "qdrant" "mdi-database-search" "Vector Search Engine")
      (lSrv "PostgreSQL" "postgres" "si-postgresql" "PG + pgvector + lantern")
      (lSrv "MaxKB" "maxkb" "mdi-book-search" "Knowledge Base")
      (lSrv "Jan" "jan" "mdi-desktop-tower-monitor" "Local AI Desktop")
      (zSrv "Hermes Workspace" "hermesWorkspace" "mdi-robot-outline" "Agent Command Center")
      (zSrv "Hermes Dashboard" "hermesDashboard" "mdi-chart-timeline-variant" "Agent Metrics & Sessions")
      (zSrv "SillyTavern" "sillytavern" "sillytavern.png" "AI Character Chat")
      (zSrv "llama.cpp" "llamaCpp" "mdi-brain" "Inference Server")
      (zSrv "Langfuse" "langfuse" "mdi-chart-line-variant" "LLM Observability")
      (zSrv "Brain Service" "brainService" "mdi-brain" "AI Brain Layer")
      (zSrv "Hermes WebUI" "hermesWebui" "mdi-react" "Web UI Dashboard")
      (zSrv "AionUi" "aionUi" "mdi-account-group" "AI Agent Cowork UI")
      (zSrv "Paperclip" "paperclip" "mdi-paperclip" "AI Team Orchestration")
      (zSrv "Mission Control" "missionControl" "mdi-rocket-launch" "Agent Control Plane")
      (zSrv "Kong Gateway" "kongGateway" "mdi-api" "Unified LLM/API Gateway")
      (zSrv "ExtremeRouter" "extremeRouter" "mdi-router-network" "AI Gateway — 154+ Providers, RTK Savings")
      (zSrv "FreeLLMPool" "freellmpool" "mdi-pool" "Free-Tier LLM Pool")
      (zSrv "FreeLLMAPI" "freellmapi" "mdi-api" "Free-Tier LLM Router")
      (zSrv "Mistral MCP" "mistralMcp" "mdi-brain" "Mistral AI Tool Server")
      (lSrv "OpenCompany" "opencompany" "mdi-office-building" "AI Workflow Canvas")
    ];

    Infrastructure = [
      (lSrv "Vaultwarden" "vaultwarden" "vaultwarden.png" "Password Manager")
      (lSrvW "Headscale" "headscale" "headscale.png" "Tailscale Control Server" {
        type = "headscale";
        url = "http://${hostOf "luffy"}:${toString ports.headscale}";
        nodeId = "\${HOMEPAGE_HEADSCALE_NODE_ID}";
        key = "\${HOMEPAGE_HEADSCALE_KEY}";
      })
      (lSrv "SearXNG" "searxng" "searxng.png" "Meta Search Engine")
      (lSrv "FileBrowser" "filebrowser" "filebrowser.png" "Web File Manager")
      (lSrv "Spacedrive" "spacedrive" "si-spacedrive" "Virtual File System")
      (lSrv "Karakeep" "karakeep" "mdi-bookmark-multiple" "Bookmark Manager")
      # Caddy reverse proxy stats — admin API on port 2019, no key needed
      (lSrvW "Caddy" "caddyAdmin" "caddy.png" "Reverse Proxy" {
        type = "caddy";
        url = "http://${hostOf "luffy"}:${toString ports.caddyAdmin}";
      })
    ];

    Communications = [
      (lSrv "Matrix Synapse" "matrixSynapse" "matrix.png" "Federated Chat Server")
      (lSrv "Element Web" "elementWeb" "element.png" "Matrix Client")
      (lSrv "Mautrix WhatsApp" "mautrixWhatsapp" "whatsapp.png" "WhatsApp Bridge")
      (lSrv "Mautrix Signal" "mautrixSignal" "signal.png" "Signal Bridge")
      (zSrv "Signal CLI" "signalCli" "si-signal" "Signal Daemon")
      (lSrv "RustDesk" "rustdeskSignal" "mdi-monitor-share" "Remote Desktop")
    ];

    Media = [
      (lSrvW "Jellyfin" "jellyfin" "jellyfin.png" "Media Server" {
        type = "jellyfin";
        url = "http://${hostOf "luffy"}:${toString ports.jellyfin}";
        key = "\${HOMEPAGE_JELLYFIN_KEY}";
        enableBlocks = true;
        enableNowPlaying = true;
        enableUser = true;
      })
      (lSrvW "Sonarr" "sonarr" "sonarr.png" "TV Series Management" {
        type = "sonarr";
        url = "http://${hostOf "luffy"}:${toString ports.sonarr}";
        key = "\${HOMEPAGE_SONARR_KEY}";
        enableQueue = true;
      })
      (lSrvW "Radarr" "radarr" "radarr.png" "Movie Management" {
        type = "radarr";
        url = "http://${hostOf "luffy"}:${toString ports.radarr}";
        key = "\${HOMEPAGE_RADARR_KEY}";
        enableQueue = true;
      })
      (lSrv "Lidarr" "lidarr" "lidarr.png" "Music Management")
      (lSrv "Readarr" "readarr" "readarr.png" "Book Management")
      (lSrvW "Prowlarr" "prowlarr" "prowlarr.png" "Indexer Manager" {
        type = "prowlarr";
        url = "http://${hostOf "luffy"}:${toString ports.prowlarr}";
        key = "\${HOMEPAGE_PROWLARR_KEY}";
      })
      (lSrv "Bazarr" "bazarr" "bazarr.png" "Subtitle Management")
      (lSrvW "qBittorrent" "qbittorrent" "qbittorrent.png" "Torrent Client" {
        type = "qbittorrent";
        url = "http://${hostOf "luffy"}:${toString ports.qbittorrent}";
        username = "admin";
        password = "adminadmin";
        enableLeechProgress = true;
        enableLeechSize = true;
      })
      (lSrv "Aria2" "aria2" "aria2.png" "Download Manager")
      (lSrv "Calibre-Web" "calibreWeb" "calibre-web.png" "E-Book Library")
      (lSrvW "Kavita" "kavita" "kavita.png" "Comic / Manga Reader" {
        type = "kavita";
        url = "http://${hostOf "luffy"}:${toString ports.kavita}";
        username = "admin";
        password = "admin";
      })
      (lSrv "Komga" "komga" "mdi-book-multiple" "Comic / Manga Library")
      (lSrvW "Your Spotify" "yourSpotify" "spotify.png" "Spotify Analytics" {
        type = "yourspotify";
        url = "http://${hostOf "luffy"}:${toString ports.yourSpotify}";
        key = "\${HOMEPAGE_SPOTIFY_KEY}";
        interval = "month";
      })
    ];

    Automation = [
      (lSrv "n8n" "n8n" "n8n.png" "Workflow Automation")
      (lSrvW "Home Assistant" "homeAssistant" "home-assistant.png" "Home Automation" {
        type = "homeassistant";
        url = "http://${hostOf "luffy"}:${toString ports.homeAssistant}";
        key = "\${HOMEPAGE_HASS_KEY}";
        custom = [
          { state = "sensor.temperature"; }
          {
            state = "sun.sun";
            label = "sun";
          }
        ];
      })
      (lSrv "Crawl4AI" "crawl4ai" "mdi-spider-web" "Web Scraper API")
      (lSrv "Skyvern UI" "skyvernUi" "mdi-weather-lightning" "Browser Automation UI")
      (lSrv "Skyvern API" "skyvernApi" "mdi-api" "Automation API")
    ];
  };

  toGroupAttrs = name: entries: { ${name} = entries; };

in
{
  options.layers.layer-20.services.config.homepage-dashboard = {
    enable = mkEnableOption "Homepage Dashboard";
    port = mkOption {
      type = types.port;
      default = 8082;
      description = "Port to expose Homepage Dashboard on";
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
    # Environment file for widget API keys — create with:
    #   HOMEPAGE_JELLYFIN_KEY=...
    #   HOMEPAGE_SONARR_KEY=...
    #   HOMEPAGE_RADARR_KEY=...
    #   HOMEPAGE_PROWLARR_KEY=...
    #   HOMEPAGE_HASS_KEY=...
    #   HOMEPAGE_HEADSCALE_KEY=...
    #   HOMEPAGE_HEADSCALE_NODE_ID=...
    #   HOMEPAGE_SPOTIFY_KEY=...
    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to env file with widget API keys (HOMEPAGE_*_KEY)";
    };
  };

  config = mkIf cfg.enable {
    services.homepage-dashboard = mkMerge [
      {
        enable = true;
        listenPort = cfg.port;
        environmentFiles = optional (cfg.environmentFile != null) cfg.environmentFile;

        settings = {
          title = "Nix Flake Pirates";
          favicon = "https://raw.githubusercontent.com/gethomepage/homepage/main/public/homepage.png";
          theme = "dark";
          color = "slate";
          # Use CSS gradient background instead of remote image for faster load
          background = {
            opacity = 0;
          };
          layout = {
            Observability = {
              style = "row";
              columns = 5;
              icon = "mdi-chart-line";
              header = true;
            };
            "AI / Agents" = {
              style = "row";
              columns = 5;
              icon = "mdi-robot";
              header = true;
            };
            Infrastructure = {
              style = "row";
              columns = 4;
              icon = "mdi-server";
              header = true;
            };
            Communications = {
              style = "row";
              columns = 3;
              icon = "mdi-chat";
              header = true;
            };
            Media = {
              style = "row";
              columns = 4;
              icon = "mdi-multimedia";
              header = true;
            };
            Automation = {
              style = "row";
              columns = 4;
              icon = "mdi-autorenew";
              header = true;
            };
          };
          headerStyle = "boxedWidgets";
          cardBlur = "sm";
          hideVersion = true;
          language = "en-GB";
          # Visual up/down status indicators for all services
          statusStyle = "dot";
          # Clean icon style for mdi/si prefixed icons
          iconStyle = "theme";
          # Consistent card heights — prevents widgets from ballooning
          useEqualHeights = true;
          # Disable update check for faster load and privacy
          disableUpdateCheck = true;
          # Quick launch — search services by typing
          quicklaunch = {
            searchDescriptions = true;
            hideInternetSearch = false;
            showSearchSuggestions = true;
          };
          bookmarks = [
            {
              Bookmarks = [
                { "search.nixos.org" = { href = "https://search.nixos.org"; }; }
                { "docs.clan.lol" = { href = "https://docs.clan.lol"; }; }
                { "GitHub" = { href = "https://github.com"; }; }
                { "YouTube" = { href = "https://youtube.com"; }; }
                { "Agentaflow" = { href = "https://agentaflow.space"; }; }
                { "wco.tv" = { href = "https://wco.tv"; }; }
                { "Searchix" = { href = "https://searchix.ovh"; }; }
                { "EverythingMoe" = { href = "https://everythingmoe.com"; }; }
                { "TorrentSeeker" = { href = "https://torrentseeker.com"; }; }
                { "AI Studio" = { href = "https://aistudio.google.com"; }; }
              ];
            }
          ];
        };

        widgets = [
          # ── Title — NFP (gradient styled via customCSS) ──
          {
            greeting = {
              text_size = "4xl";
              text = "NFP";
            };
          }
          # ── Search 1 — Perplexity (research-grade) ──
          {
            search = {
              provider = "custom";
              customSearch = "https://www.perplexity.ai/search?q=%s";
              target = "_blank";
              showSearchSuggestions = false;
            };
          }
          # ── Search 2 — SearXNG (privacy-first meta search) ──
          {
            search = {
              provider = "custom";
              customSearch = "http://${luffy}:${toString ports.searxng}/search?q=%s";
              target = "_blank";
              showSearchSuggestions = true;
            };
          }
          # ── Weather — OpenWeather (set HOMEPAGE_OPENWEATHER_KEY) ──
          {
            weather = {
              provider = "openweather";
              apiKey = "\${HOMEPAGE_OPENWEATHER_KEY}";
              units = "metric";
            };
          }
          # ── Local system resources (expanded) ──
          {
            resources = {
              label = "${hostName} System";
              cpu = true;
              memory = true;
              disk = "/";
              uptime = true;
              expanded = true;
            };
          }
          # ── Remote machine stats via Glances ──
          {
            glances = {
              label = "${remoteMachine} System";
              url = "http://${remoteIP}:${toString ports.glances}";
              cpu = true;
              mem = true;
              disk = "/";
              uptime = true;
              expanded = true;
            };
          }
          # ── Date / time — gradient styled via customCSS ──
          {
            datetime = {
              text_size = "xl";
              format = {
                dateStyle = "full";
                timeStyle = "medium";
                hour12 = false;
              };
              locale = "en-GB";
            };
          }
        ];

        services = mapAttrsToList toGroupAttrs groups;

        customCSS = gradientCSS;
      }

      (mkIf cfg.lovable.enable {
        customCSS = gradientCSS + builtins.readFile cfg.lovable.cssPath;
        customJS = builtins.readFile cfg.lovable.jsPath;
      })
    ];

    # Firewall
    networking.firewall.allowedTCPPorts = [
      cfg.port
      ports.glances
    ];

    # User / Group
    users.users.homepage-dashboard = {
      isSystemUser = true;
      group = "homepage-dashboard";
    };
    users.groups.homepage-dashboard = { };

    # Impermanence support
    environment.persistence."/persist" = mkIf config.layers.layer-10.system.config.impermanence.enable {
      directories = [
        {
          directory = "/var/lib/homepage-dashboard";
          user = "homepage-dashboard";
          group = "homepage-dashboard";
          mode = "0700";
        }
      ];
    };

    # Systemd — fix StateDirectory clash with impermanence
    systemd.services.homepage-dashboard = {
      serviceConfig = {
        StateDirectory = mkForce [ ];
        ReadWritePaths = [ "/var/lib/homepage-dashboard" ];
        Restart = "on-failure";
        RestartSec = "5s";
      };
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/homepage-dashboard 0700 homepage-dashboard homepage-dashboard -"
      "d /var/lib/homepage-dashboard/images 0755 homepage-dashboard homepage-dashboard -"
      "L+ /var/lib/homepage-dashboard/images/robin.png - - - - ${../../../layers/00-cyberia/02-assets/png-ico + "/Nico Robin.png"}"
      "L+ /var/lib/homepage-dashboard/images/vegapunk.png - - - - ${../../../layers/00-cyberia/02-assets/png-ico/Stella.png}"
      "L+ /var/lib/homepage-dashboard/images/franky.png - - - - ${../../../layers/00-cyberia/02-assets/png-ico/Franck.png}"
      "L+ /var/lib/homepage-dashboard/images/nami.png - - - - ${../../../layers/00-cyberia/02-assets/png-ico/Nami.png}"
      "L+ /var/lib/homepage-dashboard/images/sanji.png - - - - ${../../../layers/00-cyberia/02-assets/png-ico/Sanji.png}"
      "L+ /var/lib/homepage-dashboard/images/usopp.png - - - - ${../../../layers/00-cyberia/02-assets/png-ico/Usopp.png}"
      "L+ /var/lib/homepage-dashboard/images/luffy.png - - - - ${../../../layers/00-cyberia/02-assets/png-ico/Lufy.png}"
      "L+ /var/lib/homepage-dashboard/images/zoro.png - - - - ${../../../layers/00-cyberia/02-assets/png-ico/Zoro.png}"
    ]
    ++ optional config.layers.layer-10.system.config.impermanence.enable "d /persist/var/lib/homepage-dashboard 0700 homepage-dashboard homepage-dashboard -";
  };
}
