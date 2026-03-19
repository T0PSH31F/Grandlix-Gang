{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    windowrule = [
      "match:title ^(Open File)(.*)$, center on"
      "match:title ^(Open File)(.*)$, float on"
      "match:title ^(Select a File)(.*)$, center on"
      "match:title ^(Select a File)(.*)$, float on"
      "match:title ^(Choose wallpaper)(.*)$, center on"
      "match:title ^(Choose wallpaper)(.*)$, float on"
      "match:title ^(Choose wallpaper)(.*)$, size 60% 65%"
      "match:title ^(Open Folder)(.*)$, center on"
      "match:title ^(Open Folder)(.*)$, float on"
      "match:title ^(Save As)(.*)$, center on"
      "match:title ^(Save As)(.*)$, float on"
      "match:title ^(Library)(.*)$, center on"
      "match:title ^(Library)(.*)$, float on"
      "match:title ^(File Upload)(.*)$, center on"
      "match:title ^(File Upload)(.*)$, float on"
      "match:title ^(.*)(wants to save)$, center on"
      "match:title ^(.*)(wants to save)$, float on"
      "match:title ^(.*)(wants to open)$, center on"
      "match:title ^(.*)(wants to open)$, float on"

      # Specific Apps
      "match:class ^(blueberry\\.py)$, float on"
      "match:class ^(guifetch)$, float on"
      "match:class ^(pavucontrol)$, float on"
      "match:class ^(pavucontrol)$, size 45% 45%"
      "match:class ^(pavucontrol)$, center on"
      "match:class ^(org\\.pulseaudio\\.pavucontrol)$, float on"
      "match:class ^(org\\.pulseaudio\\.pavucontrol)$, size 45% 45%"
      "match:class ^(org\\.pulseaudio\\.pavucontrol)$, center on"
      "match:class ^(nm-connection-editor)$, float on"
      "match:class ^(nm-connection-editor)$, size 45% 45%"
      "match:class ^(nm-connection-editor)$, center on"
      "match:class .*plasmawindowed.*, float on"
      "match:class kcm_.*, float on"
      "match:class .*bluedevilwizard, float on"
      "match:title .*Welcome, float on"
      "match:title .*Shell conflicts.*, float on"
      "match:class org\\.freedesktop\\.impl\\.portal\\.desktop\\.kde, float on"
      "match:class org\\.freedesktop\\.impl\\.portal\\.desktop\\.kde, size 60% 65%"
      "match:class ^(Zotero)$, float on"
      "match:class ^(Zotero)$, size 45% 45%"

      # Move / Focus
      "match:class ^(plasma-changeicons)$, float on"
      "match:class ^(plasma-changeicons)$, no_initial_focus on"
      "match:class ^(plasma-changeicons)$, move 999999 999999"
      "match:title ^(Copying — Dolphin)$, move 40 80"

      # Tiling
      "match:class ^dev\\.warp\\.Warp$, tile on"

      # Picture-in-Picture
      "match:title ^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$, float on"
      "match:title ^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$, keep_aspect_ratio on"
      "match:title ^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$, move 73% 72%"
      "match:title ^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$, size 25% 25%"
      "match:title ^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$, pin on"

      # Tearing
      "match:title .*\\.exe, immediate on"
      "match:title .*minecraft.*, immediate on"
      "match:class ^(steam_app).*, immediate on"
    ];

    # ######## Workspace rules ########
    workspace = [
      "special:special, gaps_out 30"
    ];

    # ######## Layer rules ########
    layerrule = [
      "match:namespace .*, xray on"
      "match:namespace vicinae, no_anim on"
      "match:namespace selection, no_anim on"
      "match:namespace anyrun, no_anim on"
      "match:namespace hyprpicker, no_anim on"
      "match:namespace gtk-layer-shell, blur on"
      "match:namespace launcher, blur on"
      "match:namespace notifications, blur on"
      "match:namespace logout_dialog, blur on"

      # Quickshell
      "match:namespace quickshell:.*, blur_popups on"
      "match:namespace quickshell:.*, blur on"
      "match:namespace quickshell:session, blur on"
            
      # Fast Launchers
      "match:namespace gtk4-layer-shell, no_anim on"

      # Noctalia Shell
      "match:namespace ^(noctalia)$, blur on"
      "match:namespace ^(noctalia)$, xray on"
      "match:namespace ^(noctalia-shell)$, blur on"
      "match:namespace ^(noctalia-shell)$, xray on"
    ];
  };
}
