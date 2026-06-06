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
  home = lib.mkIf (cfg.enable && (cfg.terminal-toys.enable or true)) {
    home.packages = with pkgs; [
      blahaj
      cbonsai
      cfonts 
      chafa
      charasay
      cmatrix 
      figlet
      fortune-kind
      lavat 
      lolcat
      neo-cowsay
      neo
      fastfetch
      sl 
      terminal-parrot
      terminaltexteffects
      terminal-toys 
      toilet
      unimatrix
    ];
  };
}
