{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.layers.layer-70.agent.codex = {
    enable = lib.mkEnableOption "OpenAI Codex coding agent";
  };

  config = lib.mkIf config.layers.layer-70.agent.codex.enable {
    environment.systemPackages = lib.optional (pkgs ? codex) pkgs.codex;
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
