# flake-parts/features/home/cli/tools/python.nix
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.cli-environment;
in
{
  config = lib.mkIf (cfg.enable && cfg.pythonTools.enable) {
    home.packages = with pkgs; [
      uv
    ];
  };
}
