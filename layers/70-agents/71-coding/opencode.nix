{
  lib,
  pkgs,
  ...
}:
{
  options.layers.layer-70.agent.opencode = {
    enable = lib.mkEnableOption "OpenCode AI coding agent";
    desktop = lib.mkEnableOption "OpenCode desktop application";

    plugin = lib.mkOption {
      type = lib.types.enum [ "oh-my-openagent" "oh-my-opencode-slim" ];
      default = "oh-my-openagent";
      description = "Opencode plugin to load";
    };

    agents = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = "Custom agents for opencode";
    };
  };

  home =
    { config, osConfig, ... }:
    let
      pluginName = osConfig.layers.layer-70.agent.opencode.plugin;
      pluginPkg = pluginName;
      pluginLabel = if pluginName == "oh-my-openagent" then "oh-my-openagent@latest" else "oh-my-opencode-slim@latest";
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
          mcp.himalaya = {
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
          plugin = [ pluginLabel ];
          agent = {
            explore.disable = true;
            general.disable = true;
          };
          lsp = true;
        };
      };

      xdg.configFile."opencode/themes/noctalia.json".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/noctalia/templates/opencode-theme.json";

      xdg.configFile."opencode/oh-my-openagent.json".source =
        lib.mkIf (pluginName == "oh-my-openagent") ./opencode/oh-my-openagent.json;

      xdg.configFile."opencode/oh-my-opencode-slim.json".source =
        lib.mkIf (pluginName == "oh-my-opencode-slim") ./opencode/oh-my-opencode-slim.json;

      home.packages = lib.optional osConfig.layers.layer-70.agent.opencode.desktop pkgs.opencode-desktop;
    };
}
