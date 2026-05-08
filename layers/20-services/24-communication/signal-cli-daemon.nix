{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.features.services.communication.signal-cli-daemon;
in
{
  options.features.services.communication.signal-cli-daemon = {
    enable = mkEnableOption "Signal-CLI REST API Daemon";
    port = mkOption {
      type = types.port;
      default = 8090;
      description = "Port for the Signal-CLI REST API";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.signal-cli-rest-api = {
      image = "bbernhard/signal-cli-rest-api:latest";
      ports = [ "${toString cfg.port}:8080" ];
      volumes = [
        "/var/lib/signal-cli-daemon:/home/signalapi/.local/share/signal-cli"
      ];
      environment = {
        MODE = "json-rpc";
      };
    };

    # Ensure data directory exists with correct permissions for the container user
    systemd.tmpfiles.rules = [
      "d /var/lib/signal-cli-daemon 0755 root root -"
    ];

    # Persistence
    environment.persistence."/persist" = mkIf (config.features.system.config.impermanence.enable or false) {
      directories = [
        "/var/lib/signal-cli-daemon"
      ];
    };
  };
}
