# Kong AI Gateway — DB-less declarative configuration
# Deployed as OCI container via podman. Config lives in the flake at
# layers/20-services/22-ai/kong.yml — edit there, rebuild, done.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.ai-services.kong-gateway;

  # ── Declarative Kong config (structural only) ─────────────────────
  # Services, routes, upstreams, and global plugins. Consumer API keys are
  # rendered separately by the sops template "kong-consumers" and mounted
  # alongside — Kong merges both via colon-separated KONG_DECLARATIVE_CONFIG.
  kongYml = pkgs.writeText "kong-base.yml" (
    builtins.toJSON {
      _format_version = "3.0";
      _transform = true;

      # ── Services (upstream LLM routers) ──────────────────────────
      services =
        # Manifest — frontier model routing
        (optional cfg.routers.manifest.enable {
          name = "manifest-llm";
          url = "http://127.0.0.1:${toString cfg.routers.manifest.port}/v1";
          tags = [ "llm" "frontier" ];
        })
        # FreeLLMAPI — free+paid aggregated pool
        ++ (optional cfg.routers.freellmapi.enable {
          name = "freellmapi-llm";
          url = "http://127.0.0.1:${toString cfg.routers.freellmapi.port}/v1";
          tags = [ "llm" "free-first" ];
        })
        # freellmpool — pure free-tier pool
        ++ (optional cfg.routers.freellmpool.enable {
          name = "freellmpool-llm";
          url = "http://127.0.0.1:${toString cfg.routers.freellmpool.port}/v1";
          tags = [ "llm" "free-only" ];
        })
        # Coding router — mutually exclusive (omniroute or extreme-router)
        ++ (optional (cfg.routers.codingRouter == "omniroute") {
          name = "omniroute-llm";
          url = "http://127.0.0.1:${toString cfg.routers.omniroute.port}/v1";
          tags = [ "llm" "coding" ];
        })
        ++ (optional (cfg.routers.codingRouter == "extreme-router") {
          name = "extremerouter-llm";
          url = "http://127.0.0.1:${toString cfg.routers.extreme-router.port}/v1";
          tags = [ "llm" "coding" "extreme" ];
        });

      # ── Routes ───────────────────────────────────────────────────
      routes =
        # OpenAI-compatible chat completions — smart routing by model name
        [
          {
            name = "llm-chat";
            service = { name = "freellmapi-llm"; };
            paths = [ "/llm/v1/chat/completions" ];
            methods = [ "POST" ];
            tags = [ "llm" ];
          }
          {
            name = "llm-completions";
            service = { name = "freellmapi-llm"; };
            paths = [ "/llm/v1/completions" ];
            methods = [ "POST" ];
            tags = [ "llm" ];
          }
          {
            name = "llm-embeddings";
            service = { name = "freellmapi-llm"; };
            paths = [ "/llm/v1/embeddings" ];
            methods = [ "POST" ];
            tags = [ "llm" ];
          }
          # Frontier traffic → Manifest
          {
            name = "llm-frontier";
            service = { name = "manifest-llm"; };
            paths = [ "/llm/frontier/v1/chat/completions" ];
            methods = [ "POST" ];
            tags = [ "llm" "frontier" ];
          }
          # Coding traffic → OmniRoute or ExtremeRouter (mutually exclusive)
          {
            name = "llm-coding";
            service = { name = if cfg.routers.codingRouter == "extreme-router" then "extremerouter-llm" else "omniroute-llm"; };
            paths = [ "/llm/coding/v1/chat/completions" ];
            methods = [ "POST" ];
            tags = [ "llm" "coding" ];
          }
          # Free pool → freellmpool
          {
            name = "llm-free";
            service = { name = "freellmpool-llm"; };
            paths = [ "/llm/free/v1/chat/completions" ];
            methods = [ "POST" ];
            tags = [ "llm" "free" ];
          }
          # Model discovery → coding router (ExtremeRouter or OmniRoute)
          # OpenCode/Hermes call /v1/models to enumerate available models
          {
            name = "llm-models";
            service = { name = if cfg.routers.codingRouter == "extreme-router" then "extremerouter-llm" else "omniroute-llm"; };
            paths = [ "/v1/models" "/llm/v1/models" ];
            methods = [ "GET" ];
            tags = [ "llm" "models" ];
          }
          # MCP gateway
          {
            name = "mcp-gateway";
            service = { name = "freellmapi-llm"; };
            paths = [ "/mcp" ];
            methods = [ "GET" "POST" ];
            tags = [ "mcp" ];
          }
          # Health check
          {
            name = "health";
            paths = [ "/health" ];
            methods = [ "GET" ];
            plugins = [
              {
                name = "request-termination";
                config = {
                  status_code = 200;
                  content_type = "application/json";
                  body = ''{"status":"ok","gateway":"kong"}'';
                };
              }
            ];
            tags = [ "infra" ];
          }
        ];

      # ── Upstreams (for load balancing) ────────────────────────────
      upstreams =
        (optional cfg.routers.manifest.enable {
          name = "manifest-upstream";
          targets = [
            {
              target = "127.0.0.1:${toString cfg.routers.manifest.port}";
              weight = 100;
            }
          ];
          healthchecks = {
            active = {
              type = "http";
              http_path = "/api/v1/health";
              healthy = { interval = 10; };
              unhealthy = { interval = 5; };
            };
          };
        })
        ++ (optional cfg.routers.freellmapi.enable {
          name = "freellmapi-upstream";
          targets = [
            {
              target = "127.0.0.1:${toString cfg.routers.freellmapi.port}";
              weight = 100;
            }
          ];
          healthchecks = {
            active = {
              type = "http";
              http_path = "/health";
              healthy = { interval = 10; };
              unhealthy = { interval = 5; };
            };
          };
        })
        ++ (optional cfg.routers.freellmpool.enable {
          name = "freellmpool-upstream";
          targets = [
            {
              target = "127.0.0.1:${toString cfg.routers.freellmpool.port}";
              weight = 100;
            }
          ];
          healthchecks = {
            active = {
              type = "http";
              http_path = "/health";
              healthy = { interval = 10; };
              unhealthy = { interval = 5; };
            };
          };
        })
        ++ (optional (cfg.routers.codingRouter == "omniroute") {
          name = "omniroute-upstream";
          targets = [
            {
              target = "127.0.0.1:${toString cfg.routers.omniroute.port}";
              weight = 100;
            }
          ];
          healthchecks = {
            active = {
              type = "http";
              http_path = "/api/health";
              healthy = { interval = 10; };
              unhealthy = { interval = 5; };
            };
          };
        })
        ++ (optional (cfg.routers.codingRouter == "extreme-router") {
          name = "extremerouter-upstream";
          targets = [
            {
              target = "127.0.0.1:${toString cfg.routers.extreme-router.port}";
              weight = 100;
            }
          ];
          healthchecks = {
            active = {
              type = "http";
              http_path = "/api/health";
              healthy = { interval = 10; };
              unhealthy = { interval = 5; };
            };
          };
        });

      # ── Consumers (API key holders) ───────────────────────────────
      # Consumer keys are rendered by a separate sops template file and
      # merged at container start — they can't live in the Nix store.
      # See kong-consumers.yml (sops template) and the merge-init script.
      consumers = [ ];

      # ── Global plugins ────────────────────────────────────────────
      plugins = [
        # Auth — key-auth on all LLM routes
        {
          name = "key-auth";
          config = {
            key_names = [ "apikey" "Authorization" ];
            hide_credentials = true;
          };
          tags = [ "auth" ];
        }
        # Prometheus metrics
        {
          name = "prometheus";
          config = {
            per_consumer = true;
            status_code_metrics = true;
            latency_metrics = true;
            bandwidth_metrics = true;
            upstream_health_metrics = true;
          };
          tags = [ "observability" ];
        }
        # Rate limiting
        {
          name = "rate-limiting";
          config = {
            minute = 120;
            hour = 2000;
            policy = "local";
            fault_tolerant = true;
          };
          tags = [ "rate-limit" ];
        }
        # Request size limiting
        {
          name = "request-size-limiting";
          config = {
            allowed_payload_size = 10;
            size_unit = "megabytes";
          };
          tags = [ "security" ];
        }
        # CORS for browser-based agents
        {
          name = "cors";
          config = {
            origins = [ "*" ];
            methods = [ "GET" "POST" "OPTIONS" ];
            headers = [ "Accept" "Authorization" "Content-Type" "apikey" ];
            exposed_headers = [ "X-Auth-Token" ];
            credentials = true;
            max_age = 3600;
          };
          tags = [ "cors" ];
        }
      ];
    }
  );
in
{
  options.services.ai-services.kong-gateway = {
    enable = mkEnableOption "Kong AI Gateway — unified LLM/API gateway";

    proxyPort = mkOption {
      type = types.port;
      default = 8000;
      description = "Kong proxy port (API traffic)";
    };

    proxySslPort = mkOption {
      type = types.port;
      default = 8443;
      description = "Kong proxy SSL port";
    };

    adminPort = mkOption {
      type = types.port;
      default = 8001;
      description = "Kong Admin API port";
    };

    adminSslPort = mkOption {
      type = types.port;
      default = 8444;
      description = "Kong Admin API SSL port";
    };

    managerPort = mkOption {
      type = types.port;
      default = 8002;
      description = "Kong Manager GUI port";
    };

    image = mkOption {
      type = types.str;
      default = "docker.io/kong/kong:latest";
      description = "Kong Docker image";
    };

    # ── Upstream router endpoints ──────────────────────────────────
    routers = {
      manifest = {
        enable = mkEnableOption "Route traffic to Manifest" // { default = true; };
        port = mkOption { type = types.port; default = 2099; };
      };
      freellmapi = {
        enable = mkEnableOption "Route traffic to FreeLLMAPI" // { default = true; };
        port = mkOption { type = types.port; default = 3001; };
      };
      freellmpool = {
        enable = mkEnableOption "Route traffic to freellmpool" // { default = true; };
        port = mkOption { type = types.port; default = 8080; };
      };

      # Coding router — mutually exclusive. Only one can be active.
      codingRouter = mkOption {
        type = types.enum [ "omniroute" "extreme-router" ];
        default = "extreme-router";
        description = ''
          Which coding LLM router to use for /llm/coding/* traffic.
          - "omniroute": OmniRoute (231+ providers, 17 combo strategies)
          - "extreme-router": ExtremeRouter (154+ providers, RTK savings, quota tracking, 49 free providers)
          Only one can be active at a time — Kong routes accordingly.
        '';
      };

      omniroute = {
        port = mkOption { type = types.port; default = 20128; };
      };
      extreme-router = {
        port = mkOption { type = types.port; default = 20128; };
      };
    };

    # ── Consumers (clients with API keys) ──────────────────────────
    consumers = mkOption {
      type = types.listOf types.str;
      default = [ "hermes" "opencode" "claude-code" "codex" "cursor" "deerflow" ];
      description = "List of consumer usernames. Each gets a keyauth credential.";
    };

    # ── Environment file for provider keys ──────────────────────────
    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to env file with provider API keys";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/kong";
      description = "Kong data directory (logs, config)";
    };
  };

  config = mkIf cfg.enable {
    # ── Data directory ────────────────────────────────────────────
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 root root -"
      "d ${cfg.dataDir}/logs 0755 root root -"
    ];

    # ── Persist data across reboots ────────────────────────────────
    environment.persistence."/persist" = mkIf config.layers.layer-10.system.config.impermanence.enable {
      directories = [ cfg.dataDir ];
    };

    # ── Kong container ────────────────────────────────────────────
    # DB-less mode with TWO declarative config files:
    #   1. kong.base.yml  — structural (services, routes, plugins) from Nix store
    #   2. consumers.yml  — API keys rendered by sops (never enters the store)
    # Kong merges both at startup via colon-separated KONG_DECLARATIVE_CONFIG.
    virtualisation.oci-containers.containers.kong = {
      image = cfg.image;
      ports = [
        "${toString cfg.proxyPort}:8000"
        "${toString cfg.proxySslPort}:8443"
        "127.0.0.1:${toString cfg.adminPort}:8001"
        "127.0.0.1:${toString cfg.adminSslPort}:8444"
        "127.0.0.1:${toString cfg.managerPort}:8002"
      ];
      environment = {
        KONG_DATABASE = "off";
        # Colon-separated: base structural config + sops-rendered consumers
        KONG_DECLARATIVE_CONFIG = "/etc/kong/kong.base.yml:/etc/kong/consumers.yml";
        KONG_PROXY_LISTEN = "0.0.0.0:8000";
        KONG_PROXY_LISTEN_SSL = "0.0.0.0:8443";
        KONG_ADMIN_LISTEN = "0.0.0.0:8001";
        KONG_ADMIN_LISTEN_SSL = "0.0.0.0:8444";
        KONG_MANAGER_LISTEN = "0.0.0.0:8002";
        KONG_LOG_LEVEL = "info";
        KONG_PROXY_ACCESS_LOG = "/dev/stdout";
        KONG_ADMIN_ACCESS_LOG = "/dev/stdout";
        KONG_PROXY_ERROR_LOG = "/dev/stderr";
        KONG_ADMIN_ERROR_LOG = "/dev/stderr";
        KONG_PLUGINS = "bundled";
        KONG_NGINX_WORKER_PROCESSES = "2";
        KONG_NGINX_EVENTS_WORKER_CONNECTIONS = "1024";
        # DNS resolver for container networking
        KONG_DNS_RESOLVER = "127.0.0.11";
        KONG_DNS_HOSTS = "host.docker.internal";
      };
      volumes = [
        "${kongYml}:/etc/kong/kong.base.yml:ro"
        "${config.sops.templates."kong-consumers".path}:/etc/kong/consumers.yml:ro"
        # Logs go to stdout/stderr — no volume mount needed
      ];
      extraOptions = [
        "--network=host"
        "--add-host=host.docker.internal:host-gateway"
        "--health-cmd=kong health"
        "--health-interval=10s"
        "--health-timeout=5s"
        "--health-retries=5"
      ];
      environmentFiles = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
    };

    # ── Firewall ──────────────────────────────────────────────────
    networking.firewall.allowedTCPPorts = [
      cfg.proxyPort
      cfg.proxySslPort
    ];

    # ── CLI helpers ──────────────────────────────────────────────────
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "kong-ctl" ''
        DATA_DIR="${cfg.dataDir}"
        case "''${1:-help}" in
          status)
            podman exec kong kong status 2>/dev/null || echo "Kong container not running"
            ;;
          health)
            podman exec kong kong health 2>/dev/null || echo "Kong container not running"
            ;;
          reload)
            podman exec kong kong reload 2>/dev/null || echo "Kong container not running"
            ;;
          logs)
            podman logs -f kong
            ;;
          admin)
            shift
            curl -s "http://127.0.0.1:${toString cfg.adminPort}/$@" | ${pkgs.jq}/bin/jq .
            ;;
          *)
            echo "Usage: kong-ctl {status|health|reload|logs|admin <path>}"
            echo "  admin examples:"
            echo "    kong-ctl admin services"
            echo "    kong-ctl admin routes"
            echo "    kong-ctl admin consumers"
            echo "    kong-ctl admin plugins"
            echo "    kong-ctl admin upstreams"
            ;;
        esac
      '')
      (pkgs.writeShellApplication {
        name = "kong-admin";
        runtimeInputs = [ pkgs.curl pkgs.jq ];
        text = ''
          ADMIN_URL="http://127.0.0.1:${toString cfg.adminPort}"
          case "''${1:-help}" in
            services|routes|consumers|plugins|upstreams|certificates|snis)
              curl -s "$ADMIN_URL/''${1}" | jq .
              ;;
            *)
              curl -s "$ADMIN_URL/$1" | jq .
              ;;
          esac
        '';
      })
    ];
  };
}
