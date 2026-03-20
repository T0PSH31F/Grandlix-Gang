{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.desktop.hyprland;

  # ── IPC Audio Feedback Daemon ────────────────────────────────────
  hypr-sfx = pkgs.writeShellScriptBin "hypr-sfx" ''
    #!/usr/bin/env bash
    # Hyprland IPC Audio Feedback Daemon
    # Listens on Hyprland's socket2 for window events and plays UI sounds
    # via PipeWire's pw-play.

    # Ensure only one instance runs
    LOCK="/tmp/hypr-sfx-$USER.lock"
    exec 200>$LOCK
    flock -n 200 || { echo "hypr-sfx: already running." >&2; exit 0; }

    SOUND_DIR="$HOME/Clan/NFP/assets/SFX"
    SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

    # Wait for socket to exist
    for i in $(seq 1 30); do
      [ -S "$SOCKET" ] && break
      sleep 0.5
    done

    if [ ! -S "$SOCKET" ]; then
      echo "hypr-sfx: Hyprland socket2 not found, exiting." >&2
      exit 1
    fi

    LAST_MOVE=0
    play_sound() {
      local file="$SOUND_DIR/$1"
      if [ -f "$file" ]; then
        # Rate-limit movewindow sounds to 5 per second
        if [[ "$1" == "move-window.wav" ]]; then
           local now=$(date +%s%3N)
           if (( now - LAST_MOVE < 200 )); then
              return
           fi
           LAST_MOVE=$now
        fi
        # Kill any hanging pw-play processes if they take too long (avoiding build-up)
        # timeout 5s ${pkgs.pipewire}/bin/pw-play "$file" &
        # Or better: just play and disown, but the flock/single-instance check above already prevents script-level duplicates
        ${pkgs.pipewire}/bin/pw-play "$file" &
      fi
    }

    echo "hypr-sfx: Listening on $SOCKET"

    ${pkgs.socat}/bin/socat -U - UNIX-CONNECT:"$SOCKET" | while IFS= read -r line; do
      case "$line" in
        activewindow\>\>*)  play_sound "switch-focus.wav"  ;;
        movewindow\>\>*)    play_sound "move-window.wav"   ;;
        openwindow\>\>*)    play_sound "open-window.wav"   ;;
        closewindow\>\>*)   play_sound "close-window.wav"  ;;
      esac
    done
  '';

  # ── Theme Switch Master Trigger ──────────────────────────────────
  theme-switch = pkgs.writeShellScriptBin "theme-switch" ''
    #!/usr/bin/env bash
    # theme-switch.sh — Master trigger for the Noctalia dynamic theming pipeline
    # Usage: theme-switch <wallpaper_path>
    #        theme-switch --pick   (opens file picker)

    set -euo pipefail

    WALLPAPER="''${1:-}"

    # ── File picker mode ──
    if [ "$WALLPAPER" = "--pick" ] || [ -z "$WALLPAPER" ]; then
      WALLPAPER=$(find "$HOME/.background" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.webp" -o -name "*.gif" \) 2>/dev/null | shuf -n1)
      if [ -z "$WALLPAPER" ]; then
        notify-send -u critical "Theme Switch" "No wallpapers found in ~/.background/"
        exit 1
      fi
    fi

    if [ ! -f "$WALLPAPER" ]; then
      echo "Error: File not found: $WALLPAPER" >&2
      exit 1
    fi

    notify-send -t 3000 "Theme Switch" "Applying: $(basename "$WALLPAPER")"

    # ── Detect compositor ──
    COMPOSITOR="''${XDG_CURRENT_DESKTOP:-unknown}"

    # ── Step 1: Apply wallpaper ──
    EXTENSION="''${WALLPAPER##*.}"
    case "$EXTENSION" in
      mp4|webm|mkv)
        # Video wallpaper via mpvpaper (kill existing first)
        pkill mpvpaper 2>/dev/null || true
        mpvpaper -o "no-audio loop" "*" "$WALLPAPER" &
        disown
        ;;
      *)
        # Static/animated image via swww
        if ! pgrep -x swww-daemon >/dev/null; then
          ${pkgs.swww}/bin/swww-daemon &
          disown
          sleep 1
        fi
        ${pkgs.swww}/bin/swww img "$WALLPAPER" \
          --transition-type grow \
          --transition-pos 0.5,0.9 \
          --transition-duration 2 \
          --transition-fps 60
        ;;
    esac

    # ── Step 2: Command Noctalia to regenerate templates ──
    noctalia-shell ipc wallpaper setFromPath "$WALLPAPER" 2>/dev/null || true

    # ── Step 3: Wait for Noctalia's Matugen to finish generating ──
    sleep 2

    # ── Step 4: Live-reload ALL apps (async for speed) ──

    # Hyprland / Niri
    case "$COMPOSITOR" in
      Hyprland|hyprland)
        # hyprctl reload &
        # Force GPU shader recompile (toggle off then on)
        # hyprctl keyword decoration:screen_shader "" 2>/dev/null
        # sleep 0.3
        # hyprctl keyword decoration:screen_shader "$HOME/.config/hypr/vibrancy.frag" 2>/dev/null &
        ;;
      niri|Niri)
        niri msg action load-config-file &
        ;;
    esac

    # Kitty — reload colors in all instances
    if command -v kitty >/dev/null 2>&1; then
      kitty +kitten themes --reload-in=all Matugen 2>/dev/null &
    fi

    # Ghostty — SIGUSR2 triggers config reload
    pkill -SIGUSR2 ghostty 2>/dev/null &

    # Pywalfox — update Firefox/LibreWolf theme
    if command -v pywalfox >/dev/null 2>&1; then
      pywalfox update 2>/dev/null &
    fi

    # Spicetify — apply without restart
    if command -v spicetify >/dev/null 2>&1; then
      spicetify apply -n 2>/dev/null &
    fi

    # Neovim — SIGUSR1 reloads colorscheme in all instances
    pkill -SIGUSR1 nvim 2>/dev/null &

    # Btop — SIGUSR2 reloads theme
    pkill -USR2 btop 2>/dev/null &

    # Cava — SIGUSR1 reloads config
    pkill -USR1 cava 2>/dev/null &

    # GTK — toggle theme to force reload
    if command -v gsettings >/dev/null 2>&1; then
      (
        current_theme=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'")
        gsettings set org.gnome.desktop.interface gtk-theme "" 2>/dev/null
        sleep 0.2
        gsettings set org.gnome.desktop.interface gtk-theme "''${current_theme:-adw-gtk3-dark}" 2>/dev/null
      ) &
    fi

    # SwayNC — reload style
    if command -v swaync-client >/dev/null 2>&1; then
      swaync-client -rs 2>/dev/null &
    fi

    wait
    notify-send -t 3000 "Theme Switch" "All apps reloaded!"
  '';

  hypr-keybind-cheatsheet = pkgs.writeShellScriptBin "hypr-keybind-cheatsheet" ''
      #!/usr/bin/env bash
      CHEATSHEET="
    📱 LAUNCHERS & SHELL
    ─────────────────────────────────────────
    Super + A                  Noctalia Launcher
    Super + Space              Vicinae Launcher (Fast)
    Super + Tab                Noctalia Overview
    Super + X                  Control Center
    Super + Comma              Settings
    Super + L                  Lock Screen
    Ctrl + Alt + Del           Session Menu
    Super + Shift + N          Notification Center
    Super + /                  This Cheatsheet

    🪟 WINDOW MANAGEMENT
    ─────────────────────────────────────────
    Super + Q                  Kill Active Window
    Super + F                  Fullscreen
    Super + Shift + F          Maximize
    Super + Arrows             Move Focus
    Super + Shift + Arrows     Move Window
    Super + Mouse (Left)       Move Window
    Super + Mouse (Right)      Resize Window
    Super + -/=                Split Ratio
    Alt + Tab                  Cycle Windows

    🖥️ WORKSPACES
    ─────────────────────────────────────────
    Super + 1-9/0              Switch to Workspace
    Super + Shift + 1-9/0      Move to Workspace
    Super + Alt + 1-9/0        Move Silently
    Super + Ctrl + Left/Right  Previous/Next Workspace
    Super + Mouse Wheel        Scroll Workspaces
    Super + Shift + S          Toggle Special Workspace

    🎮 SCRATCHPADS
    ─────────────────────────────────────────
    Alt + T or Alt + Enter     Ghostty Dropdown Terminal
    Super + H                  Gedit Scratchpad
    Super + Shift + E          nwg-look GTK Themes

    🚀 APPLICATIONS
    ─────────────────────────────────────────
    Super + T or Return        Ghostty Terminal
    Super + Shift + T          Kitty Terminal
    Super + Shift + Return     Warp Terminal
    Super + W                  Brave Browser
    Super + Ctrl + W           LibreWolf Browser
    Super + Shift + W          Mullvad Browser
    Super + E                  Thunar File Manager
    Super + Ctrl + E           SuperFile (Terminal)
    Super + Y                  Yazelix Editor
    Super + Shift + Y          Yazi File Browser
    Super + M                  Spotify

    🎨 YAZELIX EDITOR
    ─────────────────────────────────────────
    Within Yazelix:
    Space                      Command Palette
    Space + f                  Find Files
    Space + /                  Search in Files
    Space + b                  Buffer List
    Space + w                  Save File
    Space + q                  Quit
    Ctrl + h/j/k/l             Navigate Splits
    g + d                      Go to Definition
    g + r                      Find References
    Space + e                  File Explorer Toggle
    Space + g                  Git Status

    📸 SCREENSHOTS
    ─────────────────────────────────────────
    Print                      Noctalia Screenshot
    Shift + Print              Flameshot Full Screen
    Ctrl + Print               Flameshot GUI

    🎵 MEDIA CONTROLS
    ─────────────────────────────────────────
    Alt + 4                    Previous Track
    Alt + 5                    Play/Pause
    Alt + 6                    Next Track
    Alt + 1                    Rewind 2s
    Alt + 3                    Forward 2s
    Alt + 7                    Volume Down
    Alt + 9                    Volume Up
    XF86 Media Keys            Also Supported

    💡 HINTS
    ─────────────────────────────────────────
    • Hyprspace (Super) shows all workspaces
    • Vicinae is faster for app launching
    • Noctalia provides system integration
    • Use scratchpads for quick access
    • Yazelix is Helix-based modal editor
    "
      echo "$CHEATSHEET" | ${pkgs.rofi}/bin/rofi -dmenu \
        -p "Hyprland Keybinds" \
        -theme-str 'window {width: 55%; height: 90%;}' \
        -theme-str 'listview {columns: 1;}' \
        -theme-str 'element-text {font: "monospace 9";}'
  '';

  # hypr-keybind-cheatsheet = pkgs.writeShellScriptBin "hypr-keybind-cheatsheet" ''
  #   #!/usr/bin/env bash
  #   CHEATSHEET="
  #   Mod + Enter      | Open Terminal (Kitty)
  #   Mod + Q          | Close Active Window
  #   Mod + Space      | Toggle Vicinae Search
  #   Mod + A          | Toggle App Launcher
  #   Mod + X          | Toggle Control Center
  #   Mod + Tab        | Toggle Hyprspace Overview
  #   Mod + Shift + P  | Random Theme Switch
  #   Mod + H/J/K/L    | Focus Left/Down/Up/Right
  #   Mod + Shift + H/L| Move Window Left/Right
  #   Mod + Ctrl + Enter/Bksp | Add/Remove Column
  #   "
  #   ${pkgs.libnotify}/bin/notify-send -t 10000 -u low -i preferences-desktop-keyboard "Hyprland Keybinds" "$CHEATSHEET"
  # '';

  # ── Scrolling Layout Resize / Cycle ──────────────────────────────
  #hypr-scrolling-resize = pkgs.writeShellScriptBin "hypr-scrolling-resize" ''
  #  #!/usr/bin/env bash
  #  # Toggles between 33%, 66%, and 100% width for the active window
  #  # Usage: hypr-scrolling-resize toggle

  #  MONITOR_WIDTH=$(hyprctl activeworkspace -j | ${pkgs.jq}/bin/jq -r '.monitorWidth')
  #  CURRENT_WIDTH=$(hyprctl activewindow -j | ${pkgs.jq}/bin/jq -r '.size[0]')

  #  # Calculate current percentage
  #  PCT=$(echo "scale=2; $CURRENT_WIDTH / $MONITOR_WIDTH" | ${pkgs.bc}/bin/bc -l)

  #  # Thresholds for cycle: 0.33 -> 0.5 -> 0.66
  #  if (( $(echo "$PCT < 0.4" | ${pkgs.bc}/bin/bc -l) )); then
  #    NEW_WIDTH=$(echo "$MONITOR_WIDTH * 0.5" | ${pkgs.bc}/bin/bc | cut -d. -f1)
  #  elif (( $(echo "$PCT < 0.6" | ${pkgs.bc}/bin/bc -l) )); then
  #    NEW_WIDTH=$(echo "$MONITOR_WIDTH * 0.66667" | ${pkgs.bc}/bin/bc | cut -d. -f1)
  #  else
  #    NEW_WIDTH=$(echo "$MONITOR_WIDTH * 0.33333" | ${pkgs.bc}/bin/bc | cut -d. -f1)
  #  fi

  #  # Apply resize
  #  hyprctl dispatch resizewindowpixel exact "$NEW_WIDTH" 100%,activewindow
  #'';
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [
      hypr-sfx
      theme-switch
      hypr-keybind-cheatsheet
   #  hypr-scrolling-resize
    ];
  };
}
