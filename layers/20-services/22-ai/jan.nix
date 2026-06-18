{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.ai-services.jan;
in
{
  options.services.ai-services.jan = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Install Jan AI desktop application";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.jan ];
  };
}