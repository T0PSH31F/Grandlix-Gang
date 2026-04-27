{
  config,
  lib,
  ...
}:
{
  options.features.agent.codex = {
    enable = lib.mkEnableOption "OpenAI Codex coding agent";
  };

  home = lib.mkIf config.features.agent.codex.enable {
    programs.codex = {
      enable = true;
      enableMcpIntegration = true;
      settings = {
        # Default settings
      };
    };
  };
}
