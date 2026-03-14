{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.home.agent.opencode;
in
{
  options.features.home.agent.opencode = {
    enable = lib.mkEnableOption "open source AI coding agent in the terminal";
    desktop = lib.mkEnableOption "opencode desktop application";

    agents = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = "Custom agents for opencode";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.opencode = {
      enable = true;
      enableMcpIntegration = true; # Automatically syncs with programs.mcp.servers
      web.enable = true;

      agents = ./opencode/agents;
      tools = ./opencode/tools;
      skills = ./opencode/skills;
      commands = ./opencode/commands;
      rules = ./opencode/rules.md;

      settings = {
        theme = "noctalia";
      };
    };

    # Symlink the dynamically generated theme into opencode's directory
    xdg.configFile."opencode/themes/noctalia.json".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/noctalia/templates/opencode-theme.json";

    home.packages = lib.optional cfg.desktop pkgs.opencode-desktop;
  };
}
