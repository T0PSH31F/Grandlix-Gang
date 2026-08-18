{
  config,
  pkgs,
  lib,
  osConfig ? config,
  ...
}:
let
  clanTags = osConfig.machine.tags or [ ];
  cfg = config.layers.layer-70.agent.antigravity;
  user = osConfig.layers.meta.primaryUser or "t0psh31f";
in
{
  options.layers.layer-70.agent.antigravity = {
    enable = lib.mkEnableOption "Antigravity agentic IDE & CLI" // {
      default = builtins.elem "dev" clanTags;
    };

    enableA2A = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Inter-Agent (A2A) communication with Hermes, OpenCode, and ContextForge";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      antigravity-cli
      antigravity-ide
    ];

    home-manager.users.${user} = { pkgs, ... }: {
      programs.antigravity-cli = {
        enable = true;
        settings = {
          defaultModel = "gemini-3.7-flash";
          routerUrl = "http://127.0.0.1:8090/v1";
        };
      };

      # Antigravity MCP & A2A Inter-Agent Gateway Configuration
      xdg.configFile."antigravity/mcp_config.json".text = builtins.toJSON {
        mcpServers = lib.optionalAttrs cfg.enableA2A {
          hermes-a2a = {
            url = "http://127.0.0.1:8085/mcp";
            description = "Hermes Autonomous Worker A2A Gateway";
          };
          context-forge = {
            url = "http://127.0.0.1:8083/mcp";
            description = "ContextForge Universal MCP/A2A Gateway";
          };
          mcp-nixos = {
            command = "${lib.getExe pkgs.mcp-nixos}";
            args = [ ];
          };
          github = {
            command = "${lib.getExe pkgs.github-mcp-server}";
            args = [ ];
          };
        };
      };
    };
  };
}
