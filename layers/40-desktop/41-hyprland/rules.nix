{ osConfig, lib, ... }:
let
  isLuffy = osConfig.networking.hostName == "luffy";
in
{
  wayland.windowManager.hyprland.settings = {
    windowrulev2 = [
      "center, title:^(Open File)(.*)$"
      "float, title:^(Open File)(.*)$"
      "center, title:^(Select a File)(.*)$"
      "float, title:^(Select a File)(.*)$"
      "center, title:^(Choose wallpaper)(.*)$"
      "float, title:^(Choose wallpaper)(.*)$"
      "size 60% 65%, title:^(Choose wallpaper)(.*)$"
      "center, title:^(Open Folder)(.*)$"
      "float, title:^(Open Folder)(.*)$"
      "center, title:^(Save As)(.*)$"
      "float, title:^(Save As)(.*)$"
      "center, title:^(Library)(.*)$"
      "float, title:^(Library)(.*)$"
      "center, title:^(File Upload)(.*)$"
      "float, title:^(File Upload)(.*)$"
      "center, title:^(.*)(wants to save)$"
      "float, title:^(.*)(wants to save)$"
      "center, title:^(.*)(wants to open)$"
      "float, title:^(.*)(wants to open)$"

      # Specific Apps
      "float, class:^(blueberry\\.py)$"
      "float, class:^(guifetch)$"
      "float, class:^(pavucontrol)$"
      "size 45% 45%, class:^(pavucontrol)$"
      "center, class:^(pavucontrol)$"
      "float, class:^(org\\.pulseaudio\\.pavucontrol)$"
      "size 45% 45%, class:^(org\\.pulseaudio\\.pavucontrol)$"
      "center, class:^(org\\.pulseaudio\\.pavucontrol)$"
      "float, class:^(nm-connection-editor)$"
      "size 45% 45%, class:^(nm-connection-editor)$"
      "center, class:^(nm-connection-editor)$"
      "float, class:.*plasmawindowed.*"
      "float, class:kcm_.*"
      "float, class:.*bluedevilwizard"
      "float, title:.*Welcome"
      "float, title:.*Shell conflicts.*"
      "float, class:org\\.freedesktop\\.impl\\.portal\\.desktop\\.kde"
      "size 60% 65%, class:org\\.freedesktop\\.impl\\.portal\\.desktop\\.kde"
      "float, class:^(Zotero)$"
      "size 45% 45%, class:^(Zotero)$"

      # Move / Focus
      "float, class:^(plasma-changeicons)$"
      "noinitialfocus, class:^(plasma-changeicons)$"
      "move 999999 999999, class:^(plasma-changeicons)$"
      "move 40 80, title:^(Copying — Dolphin)$"

      # Tiling
      "tile, class:^dev\\.warp\\.Warp$"

      # Picture-in-Picture
      "float, title:^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$"
      "keepaspectratio, title:^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$"
      "move 73% 72%, title:^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$"
      "size 25% 25%, title:^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$"
      "pin, title:^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$"

      # Tearing
      "immediate, title:.*\\.exe"
      "immediate, title:.*minecraft.*"
      "immediate, class:^(steam_app).*"
    ];

    # ######## Workspace rules ########
    workspace = [
      "special:special, gapsout:30"
    ];

    # ######## Layer rules ########
    layerrule = let
      baseRules = [
        "xray 1, .*"
        "noanim, vicinae"
        "noanim, selection"
        "noanim, anyrun"
        "noanim, hyprpicker"
        "blur, gtk-layer-shell"
        "blur, launcher"
        "blur, notifications"
        "blur, logout_dialog"

        # Quickshell
        "blurpopups, quickshell:.*"
        "blur, quickshell:.*"
        "blur, quickshell:session"
              
        # Fast Launchers
        "noanim, gtk4-layer-shell"

        # Noctalia Shell
        "blur, ^(noctalia)$"
        "xray 1, ^(noctalia)$"
        "blur, ^(noctalia-shell)$"
        "xray 1, ^(noctalia-shell)$"
      ];
    in if isLuffy then
      builtins.filter (rule: !(lib.strings.hasInfix "blur" rule)) baseRules
    else
      baseRules;
  };
}
