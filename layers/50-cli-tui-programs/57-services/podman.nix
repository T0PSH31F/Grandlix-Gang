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
    services.podman = {
      enable = true;
      autoUpdate = {
        enable = true;
        onCalendar = "weekly";
      };
    };
  };
}
