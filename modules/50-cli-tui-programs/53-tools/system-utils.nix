# flake-parts/features/home/cli/tools/system-utils.nix
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
  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      bottom
      btop
      fastfetch
      gping
      gotree
      htop
      iftop
      iotop
      lsof
      pciutils
      psmisc
      tree
      usbutils
      tailscale

      # Image tools
      chafa
      imagemagick
      ffmpeg

      # Archive & document tools
      p7zip
      poppler-utils

      # AI terminal assistant
      tmuxai

      # CLI Fun & Utilities
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
