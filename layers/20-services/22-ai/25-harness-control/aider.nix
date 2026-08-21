{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.ai-services.aider;
in
{
  options.services.ai-services.aider = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Install Aider AI pair programming tool";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.aider-chat ];
  };
}
