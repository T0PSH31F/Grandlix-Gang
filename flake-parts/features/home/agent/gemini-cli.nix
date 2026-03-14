{
  config,
  lib,
  ...
}:

let
  cfg = config.features.home.agent.gemini-cli;
in
{
  options.features.home.agent.gemini-cli = {
    enable = lib.mkEnableOption "AI agent that brings the power of Gemini directly into your terminal";
  };

  config = lib.mkIf cfg.enable {
    programs.gemini-cli = {
      enable = true;
      settings = {
        # Default empty settings
      };
    };
  };
}
