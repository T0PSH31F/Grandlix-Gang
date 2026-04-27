{
  config,
  lib,
  ...
}:
{
  options.features.agent.gemini-cli = {
    enable = lib.mkEnableOption "Gemini CLI agent";
  };

  home = lib.mkIf config.features.agent.gemini-cli.enable {
    programs.gemini-cli = {
      enable = true;
      settings = {
        # Default settings
      };
    };
  };
}
