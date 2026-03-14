{
  inputs,
  pkgs,
  config,
  ...
}:
{
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    devenv # devenv for dev environments
    inputs.nixai.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "video/mp4" = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "video/webm" = "mpv.desktop";
      "image/jpeg" = "mvi.desktop";
      "image/png" = "mvi.desktop";
      "image/gif" = "mvi.desktop";
      "application/pdf" = "org.pwmt.zathura.desktop";
      "text/plain" = "org.gnome.TextEditor.desktop";
      "text/markdown" = "org.gnome.TextEditor.desktop";
      "x-scheme-handler/http" = "brave-browser.desktop";
      "x-scheme-handler/https" = "brave-browser.desktop";
      "text/html" = "brave-browser.desktop";
      "inode/directory" = "nemo.desktop";
    };
    associations.added = {
      "video/mp4" = "vlc.desktop";
      "image/jpeg" = "feh.desktop";
      "text/html" = "librewolf.desktop";
      "inode/directory" = [
        ".desktop"
        "dolphin.desktop"
      ];
    };
  };

  xdg = {
    enable = true;
    configFile."mimeapps.list".force = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "${config.home.homeDirectory}/Desktop";
      documents = "${config.home.homeDirectory}/Documents";
      download = "${config.home.homeDirectory}/Downloads";
      music = "${config.home.homeDirectory}/Music";
      pictures = "${config.home.homeDirectory}/Pictures";
      publicShare = "${config.home.homeDirectory}/Public";
      templates = "${config.home.homeDirectory}/Templates";
      videos = "${config.home.homeDirectory}/Videos";
    };

    # Ensure base directories are defined (usually defaults are fine, but explicitly setting ensures consistency)
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
    cacheHome = "${config.home.homeDirectory}/.cache";
  };
  # Custom user directories
  home.file = {
    "Appimages/.keep".text = "";
    "Clan/.keep".text = "";
    "Flatpaks/.keep".text = "";
    "Games/.keep".text = "";
    "Projects/.keep".text = "";
    ".icons/.keep".text = "";
    ".cursors/.keep".text = "";
    ".themes/.keep".text = "";
  };
}
