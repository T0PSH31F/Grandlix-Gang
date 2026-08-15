{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.ai-services.polyfloor;
in
{
  options.services.ai-services.polyfloor = {
    enable = mkEnableOption "Polyfloor — Multi-floor AI company OS";

    host = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Host to bind the backend service to (loopback by default)";
    };

    port = mkOption {
      type = types.port;
      default = 8001;
      description = "Port for the Polyfloor FastAPI backend";
    };

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/polyfloor";
      description = "Persistent data directory for Polyfloor";
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to environment file with secrets (SOPS-managed)";
    };

    manageDatabase = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to create the polyfloor database and user.
        Disable when using NFP's shared PostgreSQL (default).
      '';
    };

    logLevel = mkOption {
      type = types.enum [ "debug" "info" "warning" "error" "critical" ];
      default = "info";
      description = "Backend log level";
    };
  };

  config = mkIf cfg.enable {
    # Polyfloor system user
    users.users.polyfloor = {
      isSystemUser = true;
      group = "polyfloor";
      home = cfg.dataDir;
      description = "Polyfloor service user";
    };
    users.groups.polyfloor = { };

    # Data directories
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir}          0750 polyfloor polyfloor -"
      "d ${cfg.dataDir}/floors   0750 polyfloor polyfloor -"
      "d ${cfg.dataDir}/outputs  0750 polyfloor polyfloor -"
      "d ${cfg.dataDir}/logs     0750 polyfloor polyfloor -"
    ];

    # PostgreSQL: ensure database and user exist (uses existing shared instance)
    services.postgresql = mkIf cfg.manageDatabase {
      ensureUsers = [
        {
          name = "polyfloor";
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [ "polyfloor" ];
    };

    # Polyfloor backend service — headless, no Wayland/GUI variables
    systemd.services.polyfloor-backend = {
      description = "Polyfloor FastAPI backend";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      environment = {
        POLYFLOOR_HOST = cfg.host;
        POLYFLOOR_PORT = toString cfg.port;
        POLYFLOOR_LOG_LEVEL = cfg.logLevel;
        POLYFLOOR_OUTPUT_ROOT = "${cfg.dataDir}/floors";
      };

      serviceConfig = {
        # Execution — uses uv for now; replace with packaged executable when available
        ExecStart = "${pkgs.uv}/bin/uv run uvicorn polyfloor.main:app --host ${cfg.host} --port ${toString cfg.port}";
        Restart = "on-failure";
        RestartSec = "5s";

        # User isolation
        User = "polyfloor";
        Group = "polyfloor";
        WorkingDirectory = cfg.dataDir;

        # Secrets via SOPS environment file
        EnvironmentFile = mkIf (cfg.environmentFile != null) cfg.environmentFile;

        # Hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ cfg.dataDir ];
        StateDirectory = "polyfloor";

        # Network — bind to loopback only
        IPAddressAllow = [ "127.0.0.1" "::1" ];

        # Capabilities
        CapabilityBoundingSet = "";
        AmbientCapabilities = "";
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        LockPersonality = true;
      };
    };

    # Impermanence: persist polyfloor data (opt-in, NFP controls this)
    environment.persistence."/persist" =
      mkIf (config.layers.layer-10.system.config.impermanence.enable or false)
        {
          directories = [
            {
              directory = cfg.dataDir;
              user = "polyfloor";
              group = "polyfloor";
              mode = "0750";
            }
          ];
        };
  };
}
