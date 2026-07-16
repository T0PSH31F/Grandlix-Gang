{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.layers.layer-50.cli;
  nixvimEnabled = config.layers.layer-50.cli.nixvim.enable or false;
in
{
  home = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      micro
      vim
      nano
    ] ++ lib.optional (!nixvimEnabled) neovim;
  };
}
