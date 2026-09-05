# Deprecated — moved to layers/70-agents/75-mcp/server-catalog.nix
# This file exists as a backward-compatibility alias.
# All new config should use layers.layer-75.mcp.* options.

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
