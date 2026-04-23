{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.home.agent.mcp;
in
{
  options.features.home.agent.mcp = {
    enable = lib.mkEnableOption "Model Context Protocol (MCP) servers";

    servers = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = "MCP servers to configure globally.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      kilocode-cli
      openclaw
      picoclaw
      zeroclaw
      crush
      mcp-nixos
      ha-mcp
      github-mcp-server
      perplexity-mcp
      # Any other specific MCP standard packages
    ];

    programs.mcp.enable = true;

    # We populate programs.mcp.servers with a default set of powerful utility servers
    # Merge the defaults with whatever the user might provide in cfg.servers
    programs.mcp.servers = lib.recursiveUpdate {
      browser-use = {
        command = "npx";
        args = [
          "-y"
          "@modelcontextprotocol/server-browser-use"
        ];
      };
      file-manager = {
        command = "npx";
        args = [
          "-y"
          "@modelcontextprotocol/server-file-manager"
        ];
      };
      sequential-thinking = {
        command = "npx";
        args = [
          "-y"
          "@modelcontextprotocol/server-sequential-thinking"
        ];
      };
      mcp-registry = {
        command = "npx";
        args = [
          "-y"
          "@modelcontextprotocol/server-registry"
        ];
      };
      mcp-nixos = {
        command = lib.getExe pkgs.mcp-nixos;
        args = [ ];
      };
      github = {
        command = lib.getExe pkgs.github-mcp-server;
        args = [ ];
      };
      ha-mcp = {
        command = lib.getExe pkgs.ha-mcp;
        args = [ ];
      };
    } cfg.servers;
  };
}
