{
  pkgs,
  lib,
  ...
}:
{
  home.packages = with pkgs; [
    # Icons
    candy-icons

    # GUI apps

    beekeeper-studio
    # bitwarden-desktop
    file-roller
    jellyfin-desktop
    matugen
    nextcloud-client
    nextcloud-talk-desktop
    obs-studio
    pavucontrol
    pgadmin4-desktopmode
    newelle
    # podman-desktop
    qutebrowser
    nwg-displays
    tutanota-desktop
    valent
    webull-desktop
    z-library-desktop

    # Music
    spotdl # Spotify downloader

    # Text Editors
    gedit

    # Productivity
    lsd
  ];

  # Gedit preferences via dconf
  dconf.settings = {
    "org/gnome/gedit/preferences/editor" = {
      scheme = "noctalia";
      use-default-font = false;
      editor-font = lib.mkDefault "JetBrainsMono Nerd Font 11";
      display-line-numbers = true;
      highlight-current-line = true;
      bracket-matching = true;
      auto-indent = true;
      tabs-size = lib.mkDefault 2;
      insert-spaces = true;
    };
  };

  # Programs that were in apps.nix but didn't have a better home
  programs.firefox.enable = true; # Fallback/Reference

  # Kitty and GTK are often central, but we can keep them here or move them to a theme module.
  # For now, keeping them here as per plan.
  programs.kitty = {
    enable = true;
    settings = {
      font_family = "JetBrainsMono Nerd Font";
      font_size = 16;
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "candy-icons";
      package = pkgs.candy-icons;
    };
  };
}
