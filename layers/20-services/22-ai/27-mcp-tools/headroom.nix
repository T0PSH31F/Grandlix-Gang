# Headroom — Context compression proxy for AI agents
# https://github.com/headroomlabs-ai/headroom
#
# Compresses tool outputs, logs, files, and RAG chunks before they reach the LLM.
# 20% fewer tokens for coding agents, 60-95% fewer tokens for JSON.
#
# Runs as a local proxy on port 8787. Can be used with:
#   - ExtremeRouter (as compression upstream)
#   - OpenCode (as MCP server or proxy)
#   - Any OpenAI-compatible client (as proxy)
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.ai-services.headroom;
in
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

  config = mkIf cfg.enable {
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
        ];
      };
    };

    # Open firewall port
    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
