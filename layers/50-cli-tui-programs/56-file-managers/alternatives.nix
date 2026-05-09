{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.layers.layer-50.cli;
in
{
  home = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ ranger fff ];
    programs.lf = { enable = true; settings.hidden = true; };
  };
}
