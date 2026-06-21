{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.layers.layer-76.hermes-workspace;
in
{
  options.layers.layer-76.hermes-workspace = {
    enable = lib.mkEnableOption "Hermes Workspace — web UI for Hermes Agent";

    workspaceDir = lib.mkOption {
      type = lib.types.str;
      default = "/home/t0psh31f/.hermes/hermes-workspace";
      description = "Path to the cloned hermes-workspace repository.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "Port for the workspace web UI.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Bind address (0.0.0.0 for LAN access).";
    };

    hermesApiUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://127.0.0.1:8642";
      description = "Hermes Agent gateway URL.";
    };

    hermesDashboardUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://127.0.0.1:9119";
      description = "Hermes Agent dashboard URL.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.hermes-workspace = {
      description = "Hermes Workspace Web Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      environment = {
        NODE_ENV = "production";
        PORT = toString cfg.port;
        HOST = cfg.host;
        HERMES_API_URL = cfg.hermesApiUrl;
        HERMES_DASHBOARD_URL = cfg.hermesDashboardUrl;
        HERMES_ALLOW_INSECURE_REMOTE = "1";
      };

      serviceConfig = {
        Type = "simple";
        User = "t0psh31f";
        Group = "users";
        WorkingDirectory = cfg.workspaceDir;
        ExecStart = "${pkgs.nodejs}/bin/node server-entry.js";
        EnvironmentFile = "/home/t0psh31f/.hermes/.env";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
