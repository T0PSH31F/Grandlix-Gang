{
  config,
  lib,
  ...
}:
{
  options.layers.layer-70.agent.gemini-cli = {
    enable = lib.mkEnableOption "Gemini CLI agent (alias for Antigravity)";
  };

  config = lib.mkIf config.layers.layer-70.agent.gemini-cli.enable {
    layers.layer-70.agent.antigravity.enable = true;
  };
}
