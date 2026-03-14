{
  config,
  lib,
  ...
}:

let
  cfg = config.features.home.agent.codex;
in
{
  options.features.home.agent.codex = {
    enable = lib.mkEnableOption "lightweight coding agent that runs in your terminal";
  };

  config = lib.mkIf cfg.enable {
    programs.codex = {
      enable = true;
      enableMcpIntegration = true;
      settings = {
        # Default empty settings
      };
    };
  };
}
