{
  config,
  lib,
  ...
}:
let
  cfg = config.layers.layer-50.cli;
in
{
  home = lib.mkIf cfg.enable {
    # services.local-ai = {
    #   enable = true;
    #   environment = { DEBUG = "false"; THREADS = "4"; };
    # };
  };
}
