{
  config,
  lib,
  ...
}:
{
  options.layers.layer-70.agent.codex = {
    enable = lib.mkEnableOption "OpenAI Codex coding agent";
  };

  home = lib.mkIf config.layers.layer-70.agent.codex.enable {
    programs.codex = {
      enable = true;
      enableMcpIntegration = true;
      settings = {
        # Default settings
      };
    };
  };
}
