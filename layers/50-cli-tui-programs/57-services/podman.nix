{
  config,
  lib,
  ...
}:
let
  cfg = config.features.cli;
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
