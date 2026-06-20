{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.ai-services.cherry-studio;
in
{
  options.services.ai-services.cherry-studio = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Install Cherry Studio desktop LLM client";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.cherry-studio ];

    environment.persistence."/persist" =
      mkIf (config.layers.layer-10.system.config.impermanence.enable or false)
        {
          users.t0psh31f = {
            directories = [ ".config/cherry-studio" ];
          };
        };
  };
}
