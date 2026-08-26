{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.ai-services.manifest;

  # ── Compose template ─────────────────────────────────────────────────
  # Uses ${VAR:-default} syntax so secrets come from the .env file at runtime,
  # not from the Nix store.
  composeTemplate = pkgs.writeText "docker-compose.template.yml" ''
    name: mnfst

    services:
      manifest:
        image: manifestdotbuild/manifest:latest
        ports:
          - "127.0.0.1:${toString cfg.port}:${toString cfg.port}"
        extra_hosts:
          - "host.docker.internal:host-gateway"
        environment:
          - PORT=${toString cfg.port}
          - DATABASE_URL=postgresql://manifest:''${MANIFEST_DB_PASSWORD}@postgres:5432/manifest
          - BETTER_AUTH_SECRET=''${MANIFEST_AUTH_SECRET}
          - MANIFEST_ENCRYPTION_KEY=''${MANIFEST_ENCRYPTION_KEY}
          - BETTER_AUTH_URL=http://localhost:${toString cfg.port}
          - OLLAMA_HOST=http://host.docker.internal:11434
          - PROVIDER_TIMEOUT_MS=180000
          - STREAM_WARMUP_MS=15000
          - CODEX_SEMANTIC_OUTPUT_TIMEOUT_MS=60000
          - SEED_DATA=false
          - NODE_ENV=production
          - MANIFEST_MODE=selfhosted
          - REQUEST_RECORDING_STORAGE=auto
          - REQUEST_RECORDING_FILESYSTEM_PATH=/data/request-recordings
          - REQUEST_RECORDING_RETENTION_DAYS=365
          - THROTTLE_TTL=60000
          - THROTTLE_LIMIT=100
          - DB_POOL_MAX=30
          - AUTH_DB_POOL_MAX=10
          - RUN_MIGRATIONS_ON_BOOT=true
          - SHUTDOWN_DRAIN_MS=10000
          - MANIFEST_TELEMETRY_DISABLED=1
        depends_on:
          postgres:
            condition: service_healthy
        healthcheck:
          test: ["CMD", "node", "-e", "const p=process.env.PORT||'${toString cfg.port}';fetch('http://127.0.0.1:'+p+'/api/v1/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"]
          interval: 30s
          timeout: 5s
          start_period: 90s
          retries: 3
        logging:
          driver: json-file
          options:
            max-size: "10m"
            max-file: "5"
        read_only: true
        tmpfs:
          - /tmp:size=64m
        security_opt:
          - no-new-privileges:true
        cap_drop:
          - ALL
        mem_limit: 1g
        pids_limit: 512
        volumes:
          - recordings:/data/request-recordings
        networks:
          - internal
          - frontend

      postgres:
        image: postgres:16-alpine@sha256:20edbde7749f822887a1a022ad526fde0a47d6b2be9a8364433605cf65099416
        environment:
          - POSTGRES_USER=manifest
          - POSTGRES_PASSWORD=''${MANIFEST_DB_PASSWORD}
          - POSTGRES_DB=manifest
        volumes:
          - pgdata:/var/lib/postgresql/data
        healthcheck:
          test: pg_isready -U manifest
          interval: 5s
          timeout: 3s
          retries: 5
        logging:
          driver: json-file
          options:
            max-size: "10m"
            max-file: "5"
        security_opt:
          - no-new-privileges:true
        networks:
          - internal

    networks:
      internal:
        driver: bridge
        internal: true
      frontend:
        driver: bridge

    volumes:
      pgdata:
        name: manifest_pgdata
      recordings:
        name: manifest_request_recordings
  '';

  # ── Seeded env defaults (from Nix options, overridden by runtime .env) ─
  envDefaults = concatStringsSep "\n" (
    optional (cfg.authSecret != "") "MANIFEST_AUTH_SECRET=${cfg.authSecret}"
    ++ optional (cfg.encryptionKey != "") "MANIFEST_ENCRYPTION_KEY=${cfg.encryptionKey}"
    ++ optional (cfg.dbPassword != "") "MANIFEST_DB_PASSWORD=${cfg.dbPassword}"
  );

  # ── Helper script ────────────────────────────────────────────────────
  helperPkg = pkgs.writeShellScriptBin "manifest-ctl" ''
    set -e
    DATA_DIR="${cfg.dataDir}"
    COMPOSE_FILE="$DATA_DIR/docker-compose.yml"
    ENV_FILE="$DATA_DIR/.env"

    mkdir -p "$DATA_DIR"

    # ── Write compose file ──────────────────────────────────────────────
    cp -f ${composeTemplate} "$COMPOSE_FILE"
    chmod 644 "$COMPOSE_FILE"

    # ── Ensure .env has secrets ─────────────────────────────────────────
    if [ ! -f "$ENV_FILE" ]; then
      echo "Generating secrets..."
      AUTH_SECRET=$(${pkgs.openssl}/bin/openssl rand -hex 32)
      ENC_KEY=$(${pkgs.openssl}/bin/openssl rand -hex 32)
      DB_PASS=$(${pkgs.openssl}/bin/openssl rand -hex 16)
      cat > "$ENV_FILE" << EOF
    # Manifest secrets — auto-generated. Do not share.
    MANIFEST_AUTH_SECRET=$AUTH_SECRET
    MANIFEST_ENCRYPTION_KEY=$ENC_KEY
    MANIFEST_DB_PASSWORD=$DB_PASS
    EOF
    ${optionalString (envDefaults != "") ''
      # Apply Nix-configured defaults (only for values set non-empty)
      chmod 600 "$ENV_FILE"
    ''}
      chmod 600 "$ENV_FILE"
      echo "Secrets written to $ENV_FILE"
    fi

    # ── Action dispatch ─────────────────────────────────────────────────
    case "''${1:-up}" in
      up)
        cd "$DATA_DIR"
        echo "Starting Manifest stack..."
        ${pkgs.podman-compose}/bin/podman-compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d --remove-orphans 2>&1
        ;;
      down)
        cd "$DATA_DIR"
        echo "Stopping Manifest stack..."
        ${pkgs.podman-compose}/bin/podman-compose -f "$COMPOSE_FILE" down 2>&1 || true
        ;;
      restart)
        "$0" down
        "$0" up
        ;;
      status)
        cd "$DATA_DIR"
        ${pkgs.podman-compose}/bin/podman-compose -f "$COMPOSE_FILE" ps 2>&1 || true
        ;;
      logs)
        cd "$DATA_DIR"
        shift
        ${pkgs.podman-compose}/bin/podman-compose -f "$COMPOSE_FILE" logs "$@" 2>&1 || true
        ;;
      *)
        echo "Usage: $0 {up|down|restart|status|logs}"
        exit 1
        ;;
    esac
  '';
in
{
  options.services.ai-services.manifest = {
    enable = mkEnableOption "Manifest LLM Gateway — multi-provider LLM router with OpenAI-compatible endpoint";

    port = mkOption {
      type = types.port;
      default = 2099;
      description = "Dashboard and API port";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/manifest";
      description = "Data directory for compose file and .env secrets";
    };

    authSecret = mkOption {
      type = types.str;
      default = "";
      description = "Session signing secret (openssl rand -hex 32). Auto-generated if empty.";
    };

    encryptionKey = mkOption {
      type = types.str;
      default = "";
      description = "Separate encryption key for provider credentials. Auto-generated if empty.";
    };

    dbPassword = mkOption {
      type = types.str;
      default = "";
      description = "PostgreSQL password for bundled database. Auto-generated if empty.";
    };
  };

  config = mkIf cfg.enable {
    # Ensure podman-compose is available
    environment.systemPackages = [
      pkgs.podman-compose
      helperPkg
    ];

    # Persist manifest data across reboots (includes .env with secrets)
    environment.persistence."/persist" = mkIf config.layers.layer-10.system.config.impermanence.enable {
      directories = [ cfg.dataDir ];
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0700 root root -"
    ];

    systemd.services.manifest = {
      description = "Manifest LLM Gateway — multi-provider LLM router";
      after = [
        "network-online.target"
        "podman.service"
      ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      path = with pkgs; [
        podman-compose
        podman
        openssl
        coreutils
        gnutar
        gzip
      ];

      script = ''
        ${helperPkg}/bin/manifest-ctl up
      '';

      preStop = ''
        ${helperPkg}/bin/manifest-ctl down
      '';

      serviceConfig = {
        Restart = "always";
        RestartSec = 15;
        Type = "oneshot";
        RemainAfterExit = true;
        # Hardening
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ cfg.dataDir ];
      };
    };
  };
}
