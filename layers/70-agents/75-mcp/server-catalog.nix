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

  config = lib.mkIf config.layers.layer-75.mcp.enable {
    home-manager.users.t0psh31f = {
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
        } config.layers.layer-75.mcp.servers;
      };
    };
  };
}
