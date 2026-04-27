{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.features.agent.mcp = {
    enable = lib.mkEnableOption "Model Context Protocol (MCP) servers";

    servers = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = "MCP servers to configure globally.";
    };
  };

  home = lib.mkIf config.features.agent.mcp.enable {
    home.packages = with pkgs; [
      kilocode-cli
      picoclaw
      zeroclaw
      crush
      mcp-nixos
      ha-mcp
      github-mcp-server
      perplexity-mcp
    ];

    programs.mcp = {
      enable = true;
      servers = lib.recursiveUpdate {
        browser-use = {
          command = "npx";
          args = [ "-y" "@modelcontextprotocol/server-browser-use" ];
        };
        file-manager = {
          command = "npx";
          args = [ "-y" "@modelcontextprotocol/server-file-manager" ];
        };
        sequential-thinking = {
          command = "npx";
          args = [ "-y" "@modelcontextprotocol/server-sequential-thinking" ];
        };
        mcp-registry = {
          command = "npx";
          args = [ "-y" "@modelcontextprotocol/server-registry" ];
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
      } config.features.agent.mcp.servers;
    };
  };
}
