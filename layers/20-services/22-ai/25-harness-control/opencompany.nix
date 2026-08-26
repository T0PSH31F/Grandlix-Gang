{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.ai-services.opencompany;
in
{
  options.services.ai-services.opencompany = {
    enable = lib.mkEnableOption "OpenCompany — self-hosted AI agent workflow canvas";

    port = lib.mkOption {
      type = lib.types.port;
      default = 5680;
      description = "Web UI port (default 5680 to avoid conflict with n8n on 5678)";
    };

    backendPort = lib.mkOption {
      type = lib.types.port;
      default = 5681;
      description = "Python backend port";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Bind address";
    };

    dataDir = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/opencompany";
      description = "Data directory for databases and state";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0755 opencompany opencompany -"
    ];

    users.users.opencompany = {
      isSystemUser = true;
      group = "opencompany";
      description = "OpenCompany service user";
    };
    users.groups.opencompany = { };

    systemd.services.opencompany = {
      description = "OpenCompany — AI agent workflow canvas";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      path = with pkgs; [
        nodejs_24
        bash
        git
        coreutils
        gnugrep
        gnutar
        gzip
      ];

      environment = {
        PORT = toString cfg.port;
        BACKEND_PORT = toString cfg.backendPort;
        HOST = cfg.host;
        NODE_ENV = "production";
        COMPANY_DATA_DIR = cfg.dataDir;
        NPM_CONFIG_CACHE = "${cfg.dataDir}/.npm";
      };

      serviceConfig = {
        ExecStart = "${pkgs.nodejs_24}/bin/npx @zeenie-ai/opencompany company start";
        Restart = "on-failure";
        RestartSec = 5;
        User = "opencompany";
        Group = "opencompany";
        WorkingDirectory = cfg.dataDir;
        StateDirectory = "opencompany";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "full";
        ProtectHome = true;
        ReadWritePaths = [ cfg.dataDir ];
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
