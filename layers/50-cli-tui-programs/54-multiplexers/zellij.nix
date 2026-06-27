{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.layers.layer-50.cli;

  # ── Layout Profiles ──────────────────────────────────────────────
  # KDL layout files installed to ~/.config/zellij/layouts/
  # Launch with: zellij --layout <name>

  layouts = {
    # Default development layout: nvim + lazygit split, yazi tab
    dev = ''
      layout {
        default_tab_template {
          pane size="1" {
            plugin location="zellij:tab-bar"
          }
          pane {
            children
          }
          pane size="2" {
            plugin location="zellij:status-bar"
          }
        }
        tab name="dev" {
            pane split_direction="vertical" {
              pane size="70%" {
                command "nvim"
              }
              pane size="30%" {
                command "lazygit"
              }
            }
          }
          tab name="shell" {
            pane {
              command "zsh"
            }
          }
          tab name="files" {
            pane {
              command "yazi"
            }
          }
      }
    '';
    # Git-focused layout: lazygit main pane + shell
    git = ''
      layout {
        default_tab_template {
          pane size="1" {
            plugin location="zellij:tab-bar"
          }
          pane {
            children
          }
          pane size="2" {
            plugin location="zellij:status-bar"
          }
        }
          tab name="git" {
            pane {
              command "lazygit"
            }
          }
          tab name="shell" {
            pane {
              command "zsh"
            }
          }
      }
    '';
    # Server/monitoring layout: htop + logs + shell
    server = ''
      layout {
        default_tab_template {
          pane size="1" {
            plugin location="zellij:tab-bar"
          }
          pane {
            children
          }
          pane size="2" {
            plugin location="zellij:status-bar"
          }
        }
          tab name="monitor" {
            pane split_direction="vertical" {
              pane size="50%" {
                command "htop"
              }
              pane size="50%" {
                command "journalctl" {
                  args "-f"
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

    # Git-focused layout: lazygit main pane + shell
    git = ''
      layout {
        default_tab_template {
          pane size="1" {
            plugin location="zellij:tab-bar"
          }
          pane {
            children
          }
          pane size="2" {
            plugin location="zellij:status-bar"
          }
        }
        tabs {
          tab name="git" {
            pane {
              command "lazygit"
            }
          }
          tab name="shell" {
            pane {
              command "zsh"
            }
          }
        }
      }
    '';

    # Server/monitoring layout: htop + logs + shell
    server = ''
      layout {
        default_tab_template {
          pane size="1" {
            plugin location="zellij:tab-bar"
          }
          pane {
            children
          }
          pane size="2" {
            plugin location="zellij:status-bar"
          }
        }
        tabs {
          tab name="monitor" {
            pane split_direction="vertical" {
              pane size="50%" {
                command "htop"
              }
              pane size="50%" {
                command "journalctl" {
                  args "-f"
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
      }
    '';

    # Single-pane compact (same as built-in compact, for fallback)
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
  home = lib.mkIf (cfg.enable && cfg.yazelixIntegration.enable) {
    programs.zellij = {
      enable = true;
      enableZshIntegration = false;

      settings = {
        theme = lib.mkIf cfg.theming.enable "matugen";
        pane_frames = true;
        default_layout = "dev";
        simplified_ui = true;

        # ── Scroll & Cursor Fixes ───────────────────────────────
        # scrollback_buffer_size: number of lines kept in scrollback
        scrollback_buffer_size = 10000;
        # scrollback_editor: open scrollback in nvim for search/filter
        scrollback_editor = "${lib.getExe pkgs.neovim}";
        # mouse_mode: enable mouse wheel scroll + click-to-focus
        mouse_mode = true;
        # copy_command: Wayland native clipboard
        copy_command = "wl-copy";
        # default_shell: use zsh
        default_shell = "${pkgs.zsh}/bin/zsh";

        keybinds = {
          normal = {
            "bind \"Ctrl q\"" = {
              Quit = { };
            };
            # Scroll half page up/down
            "bind \"Ctrl u\"" = {
              ScrollUp = { };
            };
            "bind \"Ctrl d\"" = {
              ScrollDown = { };
            };
          };
          pane = {
            "bind \"h\"" = {
              MoveFocus = "Left";
            };
            "bind \"j\"" = {
              MoveFocus = "Down";
            };
            "bind \"k\"" = {
              MoveFocus = "Up";
            };
            "bind \"l\"" = {
              MoveFocus = "Right";
            };
          };
          resize = {
            "bind \"h\"" = {
              Resize = "Increase Left";
            };
            "bind \"j\"" = {
              Resize = "Increase Down";
            };
            "bind \"k\"" = {
              Resize = "Increase Up";
            };
            "bind \"l\"" = {
              Resize = "Increase Right";
            };
          };
          tab = {
            # Create new tab
            "bind \"n\"" = {
              NewTab = { };
            };
            # Close current tab
            "bind \"x\"" = {
              CloseTab = { };
            };
          };
        };
      };
    };

    # Install layout profile files
    xdg.configFile = lib.mapAttrs' (name: kdl: {
      name = "zellij/layouts/${name}.kdl";
      value = { text = kdl; };
    }) layouts;

    # Shell aliases for quick layout switching
    programs.zsh.initContent = ''
      # Zellij layout aliases
      z-dev()   { zellij --layout dev; }
      z-git()   { zellij --layout git; }
      z-server(){ zellij --layout server; }
    '';
  };
}
