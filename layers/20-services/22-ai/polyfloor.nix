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
      description = "Host to bind the backend service to";
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
      description = "Whether to create the polyfloor database and user (use only if no shared PostgreSQL)";
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
    services.postgresql = mkIf (!cfg.manageDatabase) {
      ensureUsers = [
        {
          name = "polyfloor";
          ensureDBOwnership = true;
        }
      ];
      ensureDatabases = [ "polyfloor" ];
    };

    # Polyfloor backend service — headless, no Wayland variables
    systemd.services.polyfloor-backend = {
      description = "Polyfloor FastAPI backend";
      wantedBy = [ "multi-user.target" ];
      after = [ "postgresql.service" "network.target" ];

      environment = {
        POLYFLOOR_HOST = cfg.host;
        POLYFLOOR_PORT = toString cfg.port;
        POLYFLOOR_OUTPUT_ROOT = "${cfg.dataDir}/floors";
      };

      serviceConfig = {
        User = "polyfloor";
        Group = "polyfloor";
        WorkingDirectory = cfg.dataDir;
        ExecStart = "${pkgs.uv}/bin/uv run uvicorn polyfloor.main:app --host ${cfg.host} --port ${toString cfg.port}";
        Restart = "on-failure";
        RestartSec = "5s";

        # Hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ cfg.dataDir ];
        StateDirectory = "polyfloor";
      }
      // optionalAttrs (cfg.environmentFile != null) {
        EnvironmentFile = cfg.environmentFile;
      };
    };

    # Impermanence: persist polyfloor data
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
