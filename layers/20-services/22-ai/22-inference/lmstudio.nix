{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.layers.layer-20.services.ai.lmstudio;
in
{
  options.layers.layer-20.services.ai.lmstudio = {
    enable = mkEnableOption "LM Studio desktop local LLM inference application";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.lmstudio ];

    environment.persistence."/persist" =
      mkIf (config.layers.layer-10.system.config.impermanence.enable or false)
        {
          users.t0psh31f = {
            directories = [ ".config/lmstudio" ];
          };
        };
  };
}
