# flake-parts/system/fonts.nix
{ pkgs, lib, ... }:
{
  fonts = {
    enableDefaultPackages = lib.mkForce false;

    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      inter
      font-awesome
      material-design-icons
      serenityos-emoji-font
      twitter-color-emoji
      emoji-picker
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [
          "JetBrainsMono Nerd Font"
          "FiraCode Nerd Font"
        ];
        sansSerif = [ "Inter" ];
        emoji = [
          "twitter-color-emoji"
        ];
      };
    };
  };
}
