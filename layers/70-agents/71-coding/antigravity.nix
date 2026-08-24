# 🧠 Antigravity Agentic IDE & CLI
{
  config,
  pkgs,
  lib,
  osConfig ? config,
  ...
}:
let
  clanTags = if (osConfig ? machine && osConfig.machine ? tags) then osConfig.machine.tags else [ ];
  cfg = config.layers.layer-70.agent.antigravity;
in
{
  options.layers.layer-70.agent.antigravity = {
    enable = lib.mkEnableOption "Antigravity agentic IDE & CLI" // {
      default = builtins.elem "development" clanTags || builtins.elem "dev" clanTags;
    };

    enableIde = lib.mkOption {
      type = lib.types.bool;
      default = builtins.elem "desktop" clanTags;
      description = "Install Antigravity IDE GUI application in system packages";
    };

    defaultModel = lib.mkOption {
      type = lib.types.str;
      default = "gemini-3.7-flash";
      description = "Default model for Antigravity CLI";
    };

    enableA2A = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Inter-Agent (A2A) communication with Hermes, OpenCode, and ContextForge";
    };
  };

  nixos = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.antigravity-cli ]
      ++ lib.optional cfg.enableIde pkgs.antigravity-ide;
  };

  home = lib.mkIf cfg.enable {
    # Antigravity MCP & A2A Inter-Agent Gateway Configuration
    xdg.configFile."antigravity/mcp_config.json".text = builtins.toJSON {
      mcpServers = lib.optionalAttrs cfg.enableA2A {
        hermes-a2a = {
          url = "${osConfig.layers.layer-20.endpoints.hermes-gateway.baseUrl}/mcp";
          description = "Hermes Autonomous Worker A2A Gateway";
        };
        context-forge = {
          url = osConfig.layers.layer-20.endpoints.context-forge.baseUrl;
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
}
