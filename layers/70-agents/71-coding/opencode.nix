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

  home = { config, osConfig, ... }: lib.mkIf osConfig.layers.layer-70.agent.opencode.enable {
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
    };

    xdg.configFile."opencode/themes/noctalia.json".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/noctalia/templates/opencode-theme.json";

    home.packages = lib.optional osConfig.layers.layer-70.agent.opencode.desktop pkgs.opencode-desktop;
  };
}
