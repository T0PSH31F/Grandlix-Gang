# 🧠 MCP Server Catalog & Gateway
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.layers.layer-75.mcp = {
    enable = lib.mkEnableOption "MCP server catalog and gateway";

    servers = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = "MCP servers to configure globally.";
    };

    gateway = {
      enable = lib.mkEnableOption "MCP gateway aggregating all servers behind a single HTTP endpoint";
      port = lib.mkOption {
        type = lib.types.int;
        default = 8085;
        description = "MCP gateway listen port";
      };
    };
  };

  nixos = { };

  home =
    let
      cfg = config.layers.layer-75.mcp;
    in
    lib.mkIf cfg.enable {
      home.packages = with pkgs; [
        picoclaw
        zeroclaw
        crush
        mcp-nixos
        ha-mcp
        github-mcp-server
        perplexity-mcp
      ];

      xdg.configFile."mcp/config.json".text = builtins.toJSON {
        mcpServers = lib.recursiveUpdate {
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
          context-mode = {
            command = "npx";
            args = [
              "-y"
              "context-mode"
            ];
          };
        } cfg.servers;
      };
    };
}
