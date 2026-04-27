{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.cli;
in
{
  home = lib.mkIf (cfg.enable && cfg.pythonTools.enable) {
    home.packages = with pkgs; [ uv ];
  };
}
