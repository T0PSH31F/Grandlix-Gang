# ⌨️ wlr-which-key — Visual Wayland Keybinding Overlay (Vimjoyer vid74)
{
  config,
  lib,
  pkgs,
  osConfig ? config,
  ...
}:
let
  cfg =
    osConfig.layers.layer-40.desktop.frameworks.which-key
      or config.layers.layer-40.desktop.frameworks.which-key or { };
  hasDesktopTag = builtins.elem "desktop" (osConfig.machine.tags or config.machine.tags or [ ]);
in
{
  config = lib.mkIf (cfg.enable or hasDesktopTag) {
    home.packages = [ pkgs.wlr-which-key ];

    xdg.configFile."wlr-which-key/config.yaml".text = ''
      # wlr-which-key Configuration (NFP System Keybindings)
      font: "Inter 12"
      background: "#1e1e2e"
      color: "#cdd6f4"
      border: "#89b4fa"
      border_width: 2
      corner_radius: 12
      anchor: "center"
      margin_right: 0
      margin_bottom: 0

      menu:
        a:
          name: "🤖 AI Agents & Tools"
          submenu:
            h:
              name: "Hermes Desktop GUI"
              cmd: "uwsm app -- hermes-desktop"
            e:
              name: "Hermes Agent CLI"
              cmd: "uwsm app -- ghostty -e hermes"
            o:
              name: "OpenCode Desktop GUI"
              cmd: "uwsm app -- opencode-desktop"
            i:
              name: "OpenCode Interpreter (TUI)"
              cmd: "uwsm app -- ghostty -e opencode"
            c:
              name: "Claude Code"
              cmd: "uwsm app -- ghostty -e claude"
            x:
              name: "Codex CLI"
              cmd: "uwsm app -- ghostty -e codex"
            d:
              name: "DeepSeek Harness (dsh)"
              cmd: "uwsm app -- ghostty -e dsh"
            g:
              name: "Gemini CLI"
              cmd: "uwsm app -- ghostty -e gemini"
            k:
              name: "Kiro CLI"
              cmd: "uwsm app -- ghostty -e kiro-cli"
            s:
              name: "Cherry Studio"
              cmd: "uwsm app -- cherry-studio"

        f:
          name: "📁 File Managers"
          submenu:
            e:
              name: "Dolphin (GUI)"
              cmd: "uwsm app -- dolphin"
            n:
              name: "Nemo (GUI)"
              cmd: "uwsm app -- nemo"
            y:
              name: "Yazi (TUI)"
              cmd: "uwsm app -- ghostty -e yazi"
            z:
              name: "Yazelix Terminal Suite"
              cmd: "ghostty -e nu ~/.config/yazelix/nushell/scripts/core/start_yazelix.nu launch"
            s:
              name: "Superfile (TUI)"
              cmd: "uwsm app -- ghostty -e sf"

        b:
          name: "🌐 Web Browsers"
          submenu:
            b:
              name: "Brave Browser"
              cmd: "uwsm app -- brave"
            l:
              name: "LibreWolf"
              cmd: "uwsm app -- librewolf"
            m:
              name: "Mullvad Browser"
              cmd: "uwsm app -- mullvad-browser"

        t:
          name: "🖥️ Terminals"
          submenu:
            g:
              name: "Ghostty"
              cmd: "uwsm app -- ghostty"
            w:
              name: "Warp Terminal"
              cmd: "uwsm app -- warp-terminal"
            k:
              name: "Kitty"
              cmd: "uwsm app -- kitty"

        m:
          name: "🎵 Media & Control"
          submenu:
            s:
              name: "Spotify"
              cmd: "uwsm app -- spotify"
            t:
              name: "Toggle Play/Pause"
              cmd: "noctalia msg media toggle"
            n:
              name: "Next Track"
              cmd: "noctalia msg media next"
            p:
              name: "Previous Track"
              cmd: "noctalia msg media previous"
            u:
              name: "Volume Up"
              cmd: "noctalia msg volume-up"
            d:
              name: "Volume Down"
              cmd: "noctalia msg volume-down"

        s:
          name: "⚙️ System & Power"
          submenu:
            c:
              name: "Control Center"
              cmd: "noctalia msg panel-toggle control-center"
            l:
              name: "Launcher"
              cmd: "noctalia msg panel-toggle launcher"
            e:
              name: "Session Menu"
              cmd: "noctalia msg panel-toggle session"
            p:
              name: "Theme Picker"
              cmd: "theme-switch --pick"
            w:
              name: "Window Switcher"
              cmd: "noctalia msg window-switcher"
    '';
  };
}
