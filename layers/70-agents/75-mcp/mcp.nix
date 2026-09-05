# Tier: 75-mcp
# Module: mcp.nix
# Purpose: Legacy MCP configuration adapter & helper imports (redirects to layer-75).
# Option Path: layers.layer-70.agent.mcp
# Enabling Host Tags: ai-agent
# RAM Footprint: light (<300MB)
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.layers.layer-70.agent.mcp = {
    enable = lib.mkEnableOption "Model Context Protocol (MCP) servers [DEPRECATED: use layers.layer-75.mcp.enable]";
    servers = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = "MCP servers [DEPRECATED: use layers.layer-75.mcp.servers]";
    };
  };

  config = lib.mkIf config.layers.layer-70.agent.mcp.enable {
    layers.layer-75.mcp = {
      enable = lib.mkForce true;
      servers = config.layers.layer-70.agent.mcp.servers;
    };
  };
}
