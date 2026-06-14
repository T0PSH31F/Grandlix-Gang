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
    home.packages = with pkgs; [
      neovim
      micro
      vim
      nano
    ];
  };
}
