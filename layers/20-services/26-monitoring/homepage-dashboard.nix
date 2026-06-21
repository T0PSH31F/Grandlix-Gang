{ config, lib, ... }:

with lib;

let
  cfg = config.layers.layer-20.services.config.homepage-dashboard;
  hostName = config.networking.hostName or "unknown";
  isLuffy = hostName == "luffy";

  # ---------------------------------------------------------------------------
  # Address constants
  # ---------------------------------------------------------------------------
  z0r0 = "192.168.1.38";
  luffy = "127.0.0.1";

  # Almost all z0r0 ports come from their module defaults.  luffy ports are
  # serviceable via the local Nix config, but hardcoding keeps things simple
  # for a two-machine dashboard.
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

    # luffy — media
    jellyfin = 8096;
    sonarr = 8989;
    radarr = 7878;
    lidarr = 8686;
    readarr = 8787;
    prowlarr = 9696;
    bazarr = 6767;
    qbittorrent = 8080;
    aria2 = 6800;
    komga = 25600;
    calibreWeb = 8083;
    yourSpotify = 3457;
    kavita = 5000;

    # luffy — ai
    ollama = 11434;
    openWebui = 8082;
    chromadb = 8000;
    jan = 3008;
    maxkb = 32784;
    simStudio = 32790;

    # luffy — infra
    vaultwarden = 8222;
    headscale = 8086;
    searxng = 8888;
    filebrowser = 8085;
    spacedrive = 32768;

    # luffy — comms
    matrixSynapse = 8008;
    elementWeb = 8444;
    mautrixWhatsapp = 29317;
    mautrixSignal = 29318;

    # luffy — automation
    n8n = 5678;
    homeAssistant = 8123;
    crawl4ai = 32775;
    skyvernUi = 32776;
    skyvernApi = 32779;

    # luffy — monitoring
    beszel = 32772;
    glances = 61208;
  };

  # ---------------------------------------------------------------------------
  # Helpers  —  resolve the correct address based on the service's home machine
  # ---------------------------------------------------------------------------
  hostOf = machine: if machine == "z0r0" then z0r0 else luffy;

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
      host = if isLuffy then hostOf machine else "127.0.0.1";
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

  # Convenience wrappers
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

  # ---------------------------------------------------------------------------
  # Service groups
  # ---------------------------------------------------------------------------
  groups = {
    Observability = [
      (zSrv "Prometheus" "prometheus" "prometheus.png" "Metrics Collection")
      (zSrv "Loki" "loki" "loki.png" "Log Aggregation")
      (zSrv "Grafana" "grafana" "grafana.png" "Dashboards & Visualization")
      (zSrv "AdGuard Home" "adguard" "adguard-home.png" "DNS Filtering")
      (lSrv "Beszel" "beszel" "beszel.png" "Lightweight Monitoring")
      (lSrv "Glances" "glances" "glances.png" "System Overview")
    ];

    "AI / Agents" = [
      (lSrv "Ollama" "ollama" "ollama.png" "LLM Inference Server")
      (lSrv "Open WebUI" "openWebui" "open-webui.png" "Chat Frontend")
      (lSrv "ChromaDB" "chromadb" "chromadb.png" "Vector Database")
      (lSrv "MaxKB" "maxkb" "maxkb.png" "Knowledge Base")
      (lSrv "Sim Studio" "simStudio" "simstudio.png" "Agent Builder")
      (lSrv "Jan" "jan" "jan.png" "Local AI Desktop")
      (zSrv "Hermes Workspace" "hermesWorkspace" "hermes.png" "Agent Command Center")
      (zSrv "SillyTavern" "sillytavern" "sillytavern.png" "AI Character Chat")
      (zSrv "llama.cpp" "llamaCpp" "llama.png" "Inference Server")
      (zSrv "Langfuse" "langfuse" "langfuse.png" "LLM Observability")
      (zSrv "Brain Service" "brainService" "brain.png" "AI Brain Layer")
    ];

    Infrastructure = [
      (lSrv "Vaultwarden" "vaultwarden" "vaultwarden.png" "Password Manager")
      (lSrv "Headscale" "headscale" "headscale.png" "Tailscale Control Server")
      (lSrv "SearXNG" "searxng" "searxng.png" "Meta Search Engine")
      (lSrv "FileBrowser" "filebrowser" "filebrowser.png" "Web File Manager")
      (lSrv "Spacedrive" "spacedrive" "spacedrive.png" "Virtual File System")
      (lSrv "Kavita" "kavita" "kavita.png" "Comic / Manga Reader")
    ];

    Communications = [
      (lSrv "Matrix Synapse" "matrixSynapse" "matrix.png" "Federated Chat Server")
      (lSrv "Element Web" "elementWeb" "element.png" "Matrix Client")
      (lSrv "Mautrix WhatsApp" "mautrixWhatsapp" "whatsapp.png" "WhatsApp Bridge")
      (lSrv "Mautrix Signal" "mautrixSignal" "signal.png" "Signal Bridge")
      (zSrv "Signal CLI" "signalCli" "signal-cli.png" "Signal Daemon")
    ];

    Media = [
      (lSrv "Jellyfin" "jellyfin" "jellyfin.png" "Media Server")
      (lSrv "Sonarr" "sonarr" "sonarr.png" "TV Series Management")
      (lSrv "Radarr" "radarr" "radarr.png" "Movie Management")
      (lSrv "Lidarr" "lidarr" "lidarr.png" "Music Management")
      (lSrv "Readarr" "readarr" "readarr.png" "Book Management")
      (lSrv "Prowlarr" "prowlarr" "prowlarr.png" "Indexer Manager")
      (lSrv "Bazarr" "bazarr" "bazarr.png" "Subtitle Management")
      (lSrv "qBittorrent" "qbittorrent" "qbittorrent.png" "Torrent Client")
      (lSrv "Aria2" "aria2" "aria2.png" "Download Manager")
      (lSrv "Komga" "komga" "komga.png" "Comic / Manga Server")
      (lSrv "Calibre-Web" "calibreWeb" "calibre-web.png" "E-Book Library")
      (lSrv "Your Spotify" "yourSpotify" "spotify.png" "Spotify Analytics")
    ];

    Automation = [
      (lSrv "n8n" "n8n" "n8n.png" "Workflow Automation")
      (lSrv "Home Assistant" "homeAssistant" "home-assistant.png" "Home Automation")
      (lSrv "Crawl4AI" "crawl4ai" "crawl4ai.png" "Web Scraper API")
      (lSrv "Skyvern UI" "skyvernUi" "skyvern.png" "Browser Automation UI")
      (lSrv "Skyvern API" "skyvernApi" "skyvern-api.png" "Automation API")
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
  };

  config = mkIf cfg.enable {
    services.homepage-dashboard = mkMerge [
      {
        enable = true;
        listenPort = cfg.port;

        settings = {
          title = "Nix Flake Pirates";
          favicon = "https://raw.githubusercontent.com/gethomepage/homepage/main/public/homepage.png";
          theme = "dark";
          color = "slate";
          background = {
            image = "https://images.unsplash.com/photo-1451187580459-43490279c0fa?q=80&w=2672&auto=format&fit=crop";
            opacity = 0.2;
          };
          layout = {
            Observability = {
              style = "row";
              columns = 4;
              icon = "mdi-chart-line";
            };
            "AI / Agents" = {
              style = "row";
              columns = 4;
              icon = "mdi-robot";
            };
            Infrastructure = {
              style = "row";
              columns = 4;
              icon = "mdi-server";
            };
            Communications = {
              style = "row";
              columns = 3;
              icon = "mdi-chat";
            };
            Media = {
              style = "row";
              columns = 4;
              icon = "mdi-multimedia";
            };
            Automation = {
              style = "row";
              columns = 4;
              icon = "mdi-autorenew";
            };
          };
          headerStyle = "boxed";
          cardBlur = "sm";
          hideVersion = true;
          language = "en-GB";
        };

        widgets = [
          # Search 1 — Perplexity (research-grade)
          {
            search = {
              provider = "custom";
              customSearch = "https://www.perplexity.ai/search?q=%s";
              target = "_blank";
              showSearchSuggestions = false;
            };
          }
          # Search 2 — SearXNG (privacy-first meta search)
          {
            search = {
              provider = "custom";
              customSearch = "http://192.168.1.54:${toString ports.searxng}/search?q=%s";
              target = "_blank";
              showSearchSuggestions = true;
            };
          }
          # System resources
          {
            resources = {
              cpu = true;
              memory = true;
              disk = "/";
              uptime = true;
            };
          }
          # Date / time
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

        services = mapAttrsToList toGroupAttrs groups;
      }

      (mkIf cfg.lovable.enable {
        customCSS = builtins.readFile cfg.lovable.cssPath;
        customJS = builtins.readFile cfg.lovable.jsPath;
      })
    ];

    # Firewall
    networking.firewall.allowedTCPPorts = [ cfg.port ];

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
    ]
    ++ optional config.layers.layer-10.system.config.impermanence.enable "d /persist/var/lib/homepage-dashboard 0700 homepage-dashboard homepage-dashboard -";
  };
}
