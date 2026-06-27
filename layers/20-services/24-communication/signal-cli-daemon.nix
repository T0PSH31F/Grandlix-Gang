{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.layers.layer-20.services.communication.signal-cli-daemon;
  signalDataDir = "/var/lib/signal-cli-daemon";
in
{
  options.layers.layer-20.services.communication.signal-cli-daemon = {
    enable = mkEnableOption "Signal-CLI REST API Daemon";
    port = mkOption {
      type = types.port;
      default = 8080;
      description = "Port for the Signal-CLI REST API";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.signal-cli ];

    users.users.signal-cli = {
      isSystemUser = true;
      group = "signal-cli";
      home = signalDataDir;
      createHome = true;
    };
    users.groups.signal-cli = {};

    systemd.tmpfiles.rules = [
      "d ${signalDataDir} 0700 signal-cli signal-cli -"
    ];

    systemd.services.signal-cli-daemon = {
      description = "Signal-CLI REST API Daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        User = "signal-cli";
        Group = "signal-cli";
        ExecStart = "${pkgs.signal-cli}/bin/signal-cli --config ${signalDataDir} daemon --http 127.0.0.1:${toString cfg.port}";
        Restart = "on-failure";
        RestartSec = 10;
        StateDirectory = "signal-cli-daemon";
        StateDirectoryMode = "0700";
      };
    };

    environment.persistence."/persist" =
      mkIf (config.layers.layer-10.system.config.impermanence.enable or false)
        {
          users.signal-cli = {
            directories = [
              ".local/share/signal-cli"
            ];
          };
        };
  };
}
