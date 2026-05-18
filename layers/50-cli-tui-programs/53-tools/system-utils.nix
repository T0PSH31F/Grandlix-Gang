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
      bottom
      btop
      fastfetch
      gping
      htop
      iftop
      iotop
      tailscale
      chafa
      ffmpeg
      tmuxai
      blahaj
      charasay
      figlet
      fortune-kind
      gum
      lolcat
      sl
      neo-cowsay
      terminal-parrot
      toilet
    ];
    programs.rbw.enable = true;
    programs.aria2.enable = true;
    programs.aria2p.enable = true;
    programs.pistol.enable = true;
  };
}
