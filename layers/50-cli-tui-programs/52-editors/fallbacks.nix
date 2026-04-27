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
  home = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ neovim micro vim nano ];
  };
}
