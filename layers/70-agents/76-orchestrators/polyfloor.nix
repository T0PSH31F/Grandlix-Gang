# Tier: 76-orchestrators
# Module: polyfloor.nix
# Purpose: Polyfloor AI governance, policy routing, and task allocation control plane.
# Option Path: services.ai-services.polyfloor
# Enabling Host Tags: agent-orchestrator, homelab
# RAM Footprint: heavy (>1GB)
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
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
      type = types.enum [
        "debug"
        "info"
        "warning"
        "error"
        "critical"
      ];
      default = "info";
      description = "Backend log level";
    };

    package = mkOption {
      type = types.nullOr types.package;
      default = null;
      defaultText = "Polyfloor backend built from pinned source";
      description = "The Polyfloor backend package (FastAPI app).";
    };
  };

  config =
    let
      cfg = config.services.ai-services.polyfloor;

      polyfloorPkg =
        if cfg.package != null then
          cfg.package
        else
          pkgs.python3Packages.buildPythonApplication {
            pname = "polyfloor";
            version = "0.1.0";

            src = pkgs.fetchFromGitHub {
              owner = "T0PSH31F";
              repo = "Polyfloor";
              rev = "e660ac8738098ab4c28bdde2adb23c4b9a216edf";
              hash = "sha256-Wkw9PPTZ8MtusdK+DPddAAmGB2GH7SH4K1SHmFfM8R8=";
            };

            postUnpack = "sourceRoot=$sourceRoot/backend";

            pyproject = true;
            build-system = [ pkgs.python3Packages.hatchling ];

            dependencies = with pkgs.python3Packages; [
              fastapi
              uvicorn
              pydantic
              pydantic-settings
              asyncpg
              httpx
              sse-starlette
              structlog
            ];

            doCheck = false;

            meta = {
              description = "Polyfloor — Multi-floor AI company OS (FastAPI backend)";
              homepage = "https://github.com/T0PSH31F/Polyfloor";
              license = pkgs.lib.licenses.mit;
              platforms = pkgs.lib.platforms.linux;
              mainProgram = "polyfloor";
            };
          };
    in
    mkIf cfg.enable {
      users.users.polyfloor = {
        isSystemUser = true;
        group = "polyfloor";
        home = cfg.dataDir;
        description = "Polyfloor service user";
      };
      users.groups.polyfloor = { };

      systemd.tmpfiles.rules = [
        "d ${cfg.dataDir}          0750 polyfloor polyfloor -"
        "d ${cfg.dataDir}/floors   0750 polyfloor polyfloor -"
        "d ${cfg.dataDir}/outputs  0750 polyfloor polyfloor -"
        "d ${cfg.dataDir}/logs     0750 polyfloor polyfloor -"
      ];

      services.postgresql = mkIf cfg.manageDatabase {
        ensureUsers = [
          {
            name = "polyfloor";
            ensureDBOwnership = true;
          }
        ];
        ensureDatabases = [ "polyfloor" ];
      };

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
          ExecStart = "${polyfloorPkg}/bin/polyfloor";
          Restart = "on-failure";
          RestartSec = "5s";

          User = "polyfloor";
          Group = "polyfloor";
          WorkingDirectory = cfg.dataDir;

          EnvironmentFile = mkIf (cfg.environmentFile != null) cfg.environmentFile;

          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectSystem = "strict";
          ProtectHome = true;
          ReadWritePaths = [ cfg.dataDir ];
          StateDirectory = "polyfloor";

          IPAddressAllow = [
            "127.0.0.1"
            "::1"
          ];

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
