{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.services.ai-services.freellmapi;

  # FreeLLMAPI package (Node.js workspace — server + dashboard)
  freellmapiPkg = pkgs.buildNpmPackage {
    pname = "freellmapi";
    version = "latest";
    src = pkgs.fetchFromGitHub {
      owner = "tashfeenahmed";
      repo = "freellmapi";
      rev = "main";               # TODO: pin to a specific commit for reproducibility
      hash = "sha256-YuCdAI0DG/vNc211wqfu/QcywA/+n0YUdZfsCPS3zAk=";
    };

    npmDepsHash = "sha256-v4ItOBqsXZYELklP0KOhG5iR2JqpFif5h44v/tT+1A0=";

    # Node.js >= 20.18 required
    nativeBuildInputs = [ pkgs.nodejs_22 pkgs.python3 pkgs.gcc pkgs.pkg-config ];
    # better-sqlite3 native module needs kernel headers
    buildInputs = [ pkgs.linuxHeaders ];

    # Build server + client
    buildPhase = ''
      runHook preBuild
      npm run build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/freellmapi
      cp -r server/dist $out/share/freellmapi/
      cp -r client/dist $out/share/freellmapi/public
      cp -r server/node_modules $out/share/freellmapi/node_modules
      cp server/package.json $out/share/freellmapi/
      runHook postInstall
    '';

    meta = {
      description = "One OpenAI-compatible endpoint aggregating 28 free LLM providers";
      homepage = "https://github.com/tashfeenahmed/freellmapi";
      license = pkgs.lib.licenses.mit;
      platforms = pkgs.lib.platforms.linux;
    };
  };
in
{
  options.services.ai-services.freellmapi = {
    enable = lib.mkEnableOption "FreeLLMAPI — free-tier LLM router with OpenAI-compatible endpoint";

    port = lib.mkOption {
      type = lib.types.port;
      default = 3001;
      description = "HTTP API port";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Bind address";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/freellmapi";
      description = "Data directory for SQLite DB and config";
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to env file with ENCRYPTION_KEY, provider API keys, etc.";
    };

    configFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to declarative JSON config (see FREEAPI_CONFIG_PATH)";
    };

    extraEnv = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Additional environment variables";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 freellmapi freellmapi -"
    ];

    users.users.freellmapi = {
      isSystemUser = true;
      group = "freellmapi";
      description = "FreeLLMAPI service user";
    };
    users.groups.freellmapi = {};

    systemd.services.freellmapi = {
      description = "FreeLLMAPI — free-tier LLM router";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        PORT = toString cfg.port;
        HOST = cfg.host;
        FREEAPI_DB_PATH = "${cfg.dataDir}/freeapi.db";
        NODE_ENV = "production";
      } // lib.optionalAttrs (cfg.configFile != null) {
        FREEAPI_CONFIG_PATH = cfg.configFile;
      } // cfg.extraEnv;

      serviceConfig = {
        ExecStart = "${pkgs.nodejs_22}/bin/node ${freellmapiPkg}/share/freellmapi/dist/index.js";
        Restart = "on-failure";
        RestartSec = 5;
        User = "freellmapi";
        Group = "freellmapi";
        WorkingDirectory = "${freellmapiPkg}/share/freellmapi";
        EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
        # Hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [ cfg.dataDir ];
      };
    };
  };
}
