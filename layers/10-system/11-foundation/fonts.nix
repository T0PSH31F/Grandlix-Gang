# flake-parts/system/fonts.nix
{ pkgs, lib, ... }:
{
  fonts = {
    enableDefaultPackages = lib.mkForce false;

    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.symbols-only
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
          "JetBrains Mono Nerd Font"
          "Fira Code Nerd Font"
        ];
        sansSerif = [ "Inter" ];
        emoji = [
          "Twitter Color Emoji"
        ];
      };
    };
  };
}
