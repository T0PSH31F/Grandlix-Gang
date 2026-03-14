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
      htop
      iftop
      iotop
      lsof
      pciutils
      psmisc
      tree
      usbutils

      # Image tools
      chafa
      imagemagick

      # CLI Fun & Utilities
      blahaj
      charasay
      figlet
      fortune-kind
      gum
      lolcat
      neo-cowsay
      terminal-parrot
      toilet
    ];
  };
}
