{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.ai-services.lmstudio;
in
{
  options.services.ai-services.lmstudio = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Install LM Studio desktop application";
    };
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
