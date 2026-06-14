{
  config,
  lib,
  ...
}:
{
  options.layers.layer-70.agent.fabric-ai = {
    enable = lib.mkEnableOption "Fabric AI framework";
  };

  home = lib.mkIf config.layers.layer-70.agent.fabric-ai.enable {
    programs.fabric-ai = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableYtAlias = true;
      enablePatternsAliases = true;
    };
  };
}
