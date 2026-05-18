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
      blahaj
      bottom
      btop
      chafa
      charasay
      fastfetch
      ffmpeg
      figlet
      fortune-kind
      gping
      gum
      htop
      hue-plus
      hueadm
      iftop
      iotop
      lolcat
      neo-cowsay
      openhue-cli
      sl
      tailscale
      terminal-parrot
      tmuxai
      toilet
    ];
    programs.rbw.enable = true;
    programs.aria2.enable = true;
    programs.aria2p.enable = true;
    programs.pistol.enable = true;
  };
}
