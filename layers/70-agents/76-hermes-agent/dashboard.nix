{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.layers.layer-76.hermes-dashboard;
  hermesState = "${config.services.hermes-agent.stateDir}/.hermes";
  hermesPkg = config.services.hermes-agent.package;
  hermesBin = "${hermesPkg}/bin/hermes";
in
{
  options.layers.layer-76.hermes-dashboard = {
    enable = lib.mkEnableOption "Hermes Dashboard — web admin panel";

    port = lib.mkOption {
      type = lib.types.port;
      default = 9119;
      description = "Port for the dashboard.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Bind address (127.0.0.1 for local-only, 0.0.0.0 for LAN).";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.hermes-dashboard = {
      description = "Hermes Agent Web Dashboard";
      wantedBy = [ "multi-user.target" ];
      after = [
        "network.target"
        "hermes-agent.service"
      ];

      environment = {
        HERMES_HOME = hermesState;
      };

      serviceConfig = {
        Type = "simple";
        User = "t0psh31f";
        Group = "users";
        WorkingDirectory = config.services.hermes-agent.stateDir;
        ExecStart = "${hermesBin} dashboard --port ${toString cfg.port} --host ${cfg.host} --insecure --skip-build";
        EnvironmentFile = "${hermesState}/.env";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
