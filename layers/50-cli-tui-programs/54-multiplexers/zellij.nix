{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.layers.layer-50.cli;

  zjstatusWasm = "${inputs.zjstatus.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/zjstatus.wasm";

  # ── Noctalia Color Sync Script ──────────────────────────────────────
  zellij-colors-sync = pkgs.writeShellScriptBin "zellij-colors-sync" ''
    COLORS_FILE="''${HOME}/.config/hypr/noctalia/noctalia-colors.conf"
    LAYOUTS_DIR="''${HOME}/.config/zellij/layouts"
    mkdir -p "$LAYOUTS_DIR"

    PRIMARY="00e468"; SECONDARY="84d990"; SURFACE="0d150d"; TERTIARY="51d5ff"; ERROR="ffb4ab"

    if [ -f "$COLORS_FILE" ]; then
      PRIMARY=$(grep '^\$primary[[:space:]]' "$COLORS_FILE" | sed 's/.*rgb(\([a-f0-9]*\)).*/\1/' | tr -d $'\r\n' || echo "$PRIMARY")
      SECONDARY=$(grep '^\$secondary[[:space:]]' "$COLORS_FILE" | sed 's/.*rgb(\([a-f0-9]*\)).*/\1/' | tr -d $'\r\n' || echo "$SECONDARY")
      SURFACE=$(grep '^\$surface[[:space:]]' "$COLORS_FILE" | sed 's/.*rgb(\([a-f0-9]*\)).*/\1/' | tr -d $'\r\n' || echo "$SURFACE")
      TERTIARY=$(grep '^\$tertiary[[:space:]]' "$COLORS_FILE" | sed 's/.*rgb(\([a-f0-9]*\)).*/\1/' | tr -d $'\r\n' || echo "$TERTIARY")
      ERROR=$(grep '^\$error[[:space:]]' "$COLORS_FILE" | sed 's/.*rgb(\([a-f0-9]*\)).*/\1/' | tr -d $'\r\n' || echo "$ERROR")
    fi

    ZJSTATUS_WASM="${zjstatusWasm}"

    gen_bar() {
      cat <<KDL
        pane size=1 borderless=true {
            plugin location="file:''${ZJSTATUS_WASM}" {
              format_left   "#[fg=#''${SECONDARY},bold] {session} #[fg=#6c7086] {mode}"
              format_center "#[fg=#9399b2] {tabs}"
              format_right  "#[fg=#6c7086] {command_git_branch} #[fg=#''${PRIMARY}] {command_hostname} #[fg=#6c7086] {datetime}"
              format_space  ""

              border_enabled  "false"
              hide_frame_for_single_pane "true"

              mode_normal  "#[bg=#''${PRIMARY},fg=#''${SURFACE},bold] NORMAL "
              mode_resize  "#[bg=#f9e2af,fg=#''${SURFACE},bold] RESIZE "
              mode_scroll  "#[bg=#89b4fa,fg=#''${SURFACE},bold] SCROLL "
              mode_session "#[bg=#cba6f7,fg=#''${SURFACE},bold] SESSION "
              mode_tmux    "#[bg=#''${ERROR},fg=#''${SURFACE},bold] TMUX "

              tab_normal   "#[fg=#6c7086] {name} "
              tab_active   "#[fg=#''${PRIMARY},bold,italic] {name} "

              command_hostname_command     "hostname"
              command_hostname_format      " {stdout} "
              command_hostname_interval    "60"
              command_hostname_rendermode  "static"

              command_git_branch_command     "git rev-parse --abbrev-ref HEAD 2>/dev/null"
              command_git_branch_format      "#[fg=#''${SECONDARY}]  {stdout}"
              command_git_branch_interval    "10"
              command_git_branch_rendermode  "static"
              command_git_branch_cwd         "{focused_pane_cwd}"

              datetime        "#[fg=#6c7086]  {format} "
              datetime_format "%a %d %b %H:%M"
              datetime_timezone "America/Los_Angeles"
            }
          }
          children
KDL
    }

    BAR=$(gen_bar)

    rm -f "$LAYOUTS_DIR/opencode.kdl" "$LAYOUTS_DIR/compact.kdl"

    cat > "$LAYOUTS_DIR/opencode.kdl" <<KDL
      layout {
        default_tab_template {
          ''${BAR}
        }
        tab name="opencode" {
          pane split_direction="vertical" {
            pane size="70%" {
              command "opencode"
            }
            pane {
              pane split_direction="horizontal" {
                pane size="50%" {
                  command "zsh"
                }
                pane size="50%" {
                  command "zsh"
                }
              }
            }
          }
        }
        tab name="shell" {
          pane {
            command "zsh"
          }
        }
      }
KDL

    cat > "$LAYOUTS_DIR/compact.kdl" <<KDL
      layout {
        pane {
          command "zsh"
        }
      }
KDL

    echo "zjstatus synced (primary=#''${PRIMARY})"
  '';

  # ── zjstatus plugin reference ──────────────────────────────────────
  zjstatusPlugin = ''plugin location="file:${zjstatusWasm}"'';

  # ── Layouts ────────────────────────────────────────────────────────
  layouts = {
    opencode = ''
      layout {
        default_tab_template {
          pane size=1 borderless=true {
            ${zjstatusPlugin} {
              format_left   "#[fg=#84d990,bold] {session} #[fg=#6c7086] {mode}"
              format_center "#[fg=#9399b2] {tabs}"
              format_right  "#[fg=#6c7086] {command_git_branch} #[fg=#00e468] {command_hostname} #[fg=#6c7086] {datetime}"
              format_space  ""

              border_enabled  "false"
              hide_frame_for_single_pane "true"

              mode_normal  "#[bg=#00e468,fg=#0d150d,bold] NORMAL "
              mode_resize  "#[bg=#f9e2af,fg=#0d150d,bold] RESIZE "
              mode_scroll  "#[bg=#89b4fa,fg=#0d150d,bold] SCROLL "
              mode_session "#[bg=#cba6f7,fg=#0d150d,bold] SESSION "
              mode_tmux    "#[bg=#f38ba8,fg=#0d150d,bold] TMUX "

              tab_normal   "#[fg=#6c7086] {name} "
              tab_active   "#[fg=#00e468,bold,italic] {name} "

              command_hostname_command     "hostname"
              command_hostname_format      " {stdout} "
              command_hostname_interval    "60"
              command_hostname_rendermode  "static"

              command_git_branch_command     "git rev-parse --abbrev-ref HEAD 2>/dev/null"
              command_git_branch_format      "#[fg=#84d990]  {stdout}"
              command_git_branch_interval    "10"
              command_git_branch_rendermode  "static"
              command_git_branch_cwd         "{focused_pane_cwd}"

              datetime        "#[fg=#6c7086]  {format} "
              datetime_format "%a %d %b %H:%M"
              datetime_timezone "America/Los_Angeles"
            }
          }
          children
        }
        tab name="opencode" {
          pane split_direction="vertical" {
            pane size="70%" {
              command "opencode"
            }
            pane {
              pane split_direction="horizontal" {
                pane size="50%" {
                  command "zsh"
                }
                pane size="50%" {
                  command "zsh"
                }
              }
            }
          }
        }
        tab name="shell" {
          pane {
            command "zsh"
          }
        }
      }
    '';

    compact = ''
      layout {
        pane {
          command "zsh"
        }
      }
    '';
  };

in
{
  home = lib.mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      enableZshIntegration = true;

      settings = {
        pane_frames = true;
        default_layout = "opencode";
        simplified_ui = false;
        scrollback_buffer_size = 50000;
        scrollback_editor = "${lib.getExe pkgs.neovim}";
        mouse_mode = false;
        copy_command = "wl-copy";
        default_shell = "${pkgs.zsh}/bin/zsh";
        auto_copy_on_select = false;
      };
    };

    xdg.configFile = lib.mapAttrs' (name: kdl: {
      name = "zellij/layouts/${name}.kdl";
      value = { text = kdl; };
    }) layouts;

    programs.zsh.initContent = ''
      z-oc() { zellij --layout opencode; }
    '';

    systemd.user.services.zellij-colors = {
      Unit = {
        Description = "Sync zjstatus layouts with Noctalia colors";
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${zellij-colors-sync}/bin/zellij-colors-sync";
      };
      Install = { WantedBy = [ "graphical-session.target" ]; };
    };

    home.packages = [ zellij-colors-sync ];
  };
}