{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.layers.layer-20.services.communication.signal-cli-daemon;
in
{
  options.layers.layer-20.services.communication.signal-cli-daemon = {
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
      extraOptions = [
        "--network=host" # Avoid aardvark-dns port 53 conflict with AdGuard
      ];
    };

    # Ensure data directory exists with correct permissions for the container user
    systemd.tmpfiles.rules = [
      "d /var/lib/signal-cli-daemon 0755 root root -"
    ];

    # Persistence
    environment.persistence."/persist" =
      mkIf (config.layers.layer-10.system.config.impermanence.enable or false)
        {
          directories = [
            "/var/lib/signal-cli-daemon"
          ];
        };
  };
}
