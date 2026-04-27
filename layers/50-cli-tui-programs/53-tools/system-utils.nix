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
    home.packages = with pkgs; [
      bottom btop fastfetch gping gotree htop iftop iotop lsof pciutils psmisc
      tree usbutils tailscale chafa imagemagick ffmpeg p7zip poppler-utils
      tmuxai blahaj charasay figlet fortune-kind gum lolcat sl neo-cowsay
      terminal-parrot toilet
    ];
    programs.rbw.enable = true;
    programs.aria2.enable = true;
    programs.aria2p.enable = true;
    programs.pistol.enable = true;
  };
}
