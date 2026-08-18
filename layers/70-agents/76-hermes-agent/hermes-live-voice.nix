# Hermes Live Voice — continuous voice layer for Hermes Agent
# https://github.com/bielcarpi/hermes-live-voice
#
# Real-time voice, background work, and live progress.
# Requires Hermes Agent 0.18.2+ and Node.js 20+.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.layers.layer-76.hermes-live-voice;
in
{
  options.layers.layer-76.hermes-live-voice = {
    enable = mkEnableOption "Hermes Live Voice — continuous voice layer for Hermes Agent";

    port = mkOption {
      type = types.port;
      default = 8880;
      description = "Port for Hermes Live Voice gateway";
    };
  };

  config = mkIf cfg.enable {
    # Install hermes-live-voice globally
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "hermes-live" ''
        exec ${pkgs.nodejs}/bin/npx hermes-live-voice "$@"
      '')
    ];

    # Run hermes-live gateway as a systemd service
    systemd.services.hermes-live-gateway = {
      description = "Hermes Live Voice gateway";
      after = [ "network.target" "hermes-agent.service" ];
      wants = [ "hermes-agent.service" ];
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [ nodejs bash git coreutils gnugrep gnutar gzip ];

      serviceConfig = {
        ExecStart = "${pkgs.nodejs}/bin/npx hermes-live-voice start --port ${toString cfg.port}";
        Restart = "always";
        RestartSec = 5;
        Environment = [
          "HERMES_HOME=/var/lib/hermes/.hermes"
          "HERMES_LIVE_PORT=${toString cfg.port}"
          "NODE_ENV=production"
        ];
      };
    };

    # Open firewall port
    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
