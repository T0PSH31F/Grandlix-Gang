{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.features.home.agent.claude-code;
in
{
  options.features.home.agent.claude-code = {
    enable = lib.mkEnableOption "agentic coding tool that lives in your terminal powered by Anthropic";
  };

  config = lib.mkIf cfg.enable {
    programs.claude-code = {
      enable = true;
      enableMcpIntegration = true; # Automatically integrates MCP config
      settings = {
        # Default empty settings
      };
    };

    home.packages = [
      (pkgs.vscode-extension-anthropic-claude-code or null) # Optional if using vscode
    ];
  };
}
