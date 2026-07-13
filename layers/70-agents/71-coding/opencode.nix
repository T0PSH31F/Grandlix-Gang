{
  lib,
  pkgs,
  ...
}:
{
  options.layers.layer-70.agent.opencode = {
    enable = lib.mkEnableOption "OpenCode AI coding agent";
    desktop = lib.mkEnableOption "OpenCode desktop application";

    agents = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = "Custom agents for opencode";
    };
  };

  home =
    { config, osConfig, ... }:
    let
      pluginLabel = "oh-my-opencode-slim@latest";
    in
    lib.mkIf osConfig.layers.layer-70.agent.opencode.enable {
      programs.opencode = {
        enable = true;
        enableMcpIntegration = true;
        web.enable = true;

        agents = ./opencode/agents;
        tools = ./opencode/tools;
        skills = ./opencode/skills;
        commands = ./opencode/commands;
        context = ./opencode/rules.md;

        tui.theme = lib.mkForce "noctalia";

        settings = {
          mcp = {
            himalaya = {
              command = [
                "node"
                "/home/t0psh31f/Projects/himalaya-mcp/dist/index.js"
              ];
              enabled = true;
              type = "local";
              env = {
                HIMALAYA_ACCOUNT = "wrighterik77";
                HIMALAYA_FOLDER = "INBOX";
                HIMALAYA_BINARY = "/etc/profiles/per-user/t0psh31f/bin/himalaya";
              };
            };
            # Disabled — consistently failing (100% error rate), not needed
            browser-use.enabled = false;
            file-manager.enabled = false;
            ha-mcp.enabled = false;
            mcp-registry.enabled = false;
            sequential-thinking.enabled = false;
          };
          plugin = [
            pluginLabel
            "@pantheon-ai/opencode-warcraft-notifications"
          ];

          agent = {
            explore.disable = true;
            general.disable = true;
          };
          lsp = true;
        };
      };

      xdg.configFile = {
        "opencode/plugin.json".text = builtins.toJSON {
          "@pantheon-ai/opencode-warcraft-notifications" = {
            faction = "horde";
            showDescriptionInToast = true;
          };
        };
        "opencode/themes/noctalia.json".source =
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/noctalia/templates/opencode-theme.json";
        "opencode/oh-my-opencode-slim.json".source = ./opencode/oh-my-opencode-slim.json;
      };

      home.packages = lib.optional osConfig.layers.layer-70.agent.opencode.desktop pkgs.opencode-desktop
        ++ [
          pkgs.libcanberra-gtk3  # canberra-gtk-play for warcraft-notifications fallback
          pkgs.alsa-utils        # aplay for warcraft-notifications wav playback
        ];
    };
}
