{
  config,
  lib,
  ...
}:

let
  cfg = config.features.home.agent.fabric-ai;
in
{
  options.features.home.agent.fabric-ai = {
    enable = lib.mkEnableOption "open-source framework for augmenting humans using AI";
  };

  config = lib.mkIf cfg.enable {
    programs.fabric-ai = {
      enable = true;
    };
  };
}
