{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.layers.layer-70.agent.claude-code = {
    enable = lib.mkEnableOption "Anthropic Claude Code agentic coding tool";
  };

  config = lib.mkIf config.layers.layer-70.agent.claude-code.enable {
    environment.systemPackages = lib.optional (pkgs ? claude-code) pkgs.claude-code;
  };

  home = lib.mkIf config.layers.layer-70.agent.claude-code.enable {
    programs.claude-code = {
      enable = true;
      enableMcpIntegration = true;
      settings = {
        # Default settings can be placed here
      };
    };

    home.packages = lib.optional (
      pkgs ? vscode-extension-anthropic-claude-code
    ) pkgs.vscode-extension-anthropic-claude-code;
  };
}
