{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.ai-services.mission-control;
in
{
  options.services.ai-services.mission-control = {
    enable = mkEnableOption "Mission Control — self-hosted AI agent control plane";

    port = mkOption {
      type = types.port;
      default = 3099;
      description = "Port for Mission Control web UI (3000 conflicts with Hermes Workspace)";
    };

    dataDir = mkOption {
      type = types.str;
      default = "/var/lib/mission-control";
      description = "Persistent data directory";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.mission-control = {
      image = "ghcr.io/builderz-labs/mission-control:latest";
      ports = [ "${toString cfg.port}:3000" ];
      volumes = [ "${cfg.dataDir}:/app/.data" ];
      environment = {
        MISSION_CONTROL_DATA_DIR = "/app/.data";
      };
      extraOptions = [
        "--userns=keep-id"
      ];
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];

    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0777 root root -"
    ];
  };
}
