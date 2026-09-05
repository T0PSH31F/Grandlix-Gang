# Tier: 75-mcp
# Module: headroom.nix
# Purpose: Headroom MCP server wrapper & context compression proxy.
# Option Path: services.ai-services.headroom
# Enabling Host Tags: ai-agent, homelab
# RAM Footprint: medium (300MB-1GB)
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.services.ai-services.headroom = {
    enable = mkEnableOption "Headroom — context compression proxy for AI agents";

    port = mkOption {
      type = types.port;
      default = 8787;
      description = "Port for Headroom proxy";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.headroom-ai;
      description = "Headroom package";
    };
  };

  config =
    let
      cfg = config.services.ai-services.headroom;
    in
    mkIf cfg.enable {
      # Install headroom globally
      environment.systemPackages = [ cfg.package ];

      # Run headroom proxy as a systemd service
      systemd.services.headroom-proxy = {
        description = "Headroom context compression proxy";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          ExecStart = "${cfg.package}/bin/headroom proxy --port ${toString cfg.port}";
          Restart = "always";
          RestartSec = 5;
          Environment = [
            "HEADROOM_PORT=${toString cfg.port}"
            "HEADROOM_HOST=127.0.0.1"
            "OPENAI_BASE_URL=http://127.0.0.1:20128/v1"
            "EXTREMEROUTER_BASE_URL=http://127.0.0.1:20128/v1"
          ];
        };
      };

      # Open firewall port
      networking.firewall.allowedTCPPorts = [ cfg.port ];
    };
}
