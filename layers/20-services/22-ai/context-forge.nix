{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.ai-services.context-forge;
in
{
  options.services.ai-services.context-forge = {
    enable = mkEnableOption "ContextForge MCP/A2A gateway";

    port = mkOption {
      type = types.port;
      default = 8094;
      description = "Port for ContextForge gateway";
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers.containers.context-forge = {
      image = "ghcr.io/ibm/mcp-context-forge:latest";
      ports = [ "${toString cfg.port}:8083" ];
      extraOptions = [ "--network=host" ];
      environment = {
        PORT = toString cfg.port;
      };
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
