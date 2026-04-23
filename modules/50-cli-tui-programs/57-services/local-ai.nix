# flake-parts/features/home/cli/services/local-ai.nix
#
# LocalAI — Local OpenAI-compatible API (home-manager user service)
#
# NOTE: local-ai is currently marked as broken in nixpkgs.
# This module is ready to enable once the package is fixed upstream.
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
    # Uncomment when local-ai is no longer broken in nixpkgs:
    # services.local-ai = {
    #   enable = true;
    #   environment = {
    #     DEBUG = "false";
    #     THREADS = "4";
    #   };
    # };
  };
}
