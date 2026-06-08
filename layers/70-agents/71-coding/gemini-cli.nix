{
  config,
  lib,
  ...
}:
{
  options.layers.layer-70.agent.gemini-cli = {
    enable = lib.mkEnableOption "Gemini CLI agent";
  };

  home = lib.mkIf config.layers.layer-70.agent.gemini-cli.enable {
    programs.gemini-cli = {
      enable = true;
      settings = {
        # Default settings
      };
    };
  };
}
