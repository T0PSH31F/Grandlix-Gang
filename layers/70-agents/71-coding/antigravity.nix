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
  user = if (osConfig ? layers && osConfig.layers ? meta) then osConfig.layers.meta.primaryUser else "t0psh31f";
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

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !(osConfig ? machine) || (osConfig.machine ? tags);
        message = "antigravity.nix requires an osConfig with machine.tags when used in NixOS context.";
      }
    ];

    environment.systemPackages = [ pkgs.antigravity-cli ]
      ++ lib.optional cfg.enableIde pkgs.antigravity-ide;

    home-manager.users.${user} = { pkgs, ... }: {
      programs.antigravity-cli = {
        enable = true;
        settings = {
          defaultModel = cfg.defaultModel;
          routerUrl = lib.mkIf (osConfig.services.ai-services.kong-gateway.enable or false)
            "http://127.0.0.1:${toString osConfig.services.ai-services.kong-gateway.proxyPort}/v1";
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
