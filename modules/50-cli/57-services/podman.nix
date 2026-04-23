# flake-parts/features/home/cli/services/podman.nix
#
# Podman — Rootless daemonless container engine (home-manager user service)
{
  config,
  lib,
  ...
}:

let
  cfg = config.programs.cli-environment;
in
{
  config = lib.mkIf cfg.enable {
    services.podman = {
      enable = true;
      autoUpdate = {
        enable = true;
        onCalendar = "weekly";
      };
    };
  };
}
