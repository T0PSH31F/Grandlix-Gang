{
  config,
  lib,
  pkgs,
  inputs,
  osConfig ? config,
  ...
}:
let
  cfg = osConfig.layers.layer-40.desktop.noctalia;
  hasDesktopTag = builtins.elem "desktop" (osConfig.machine.tags or [ ]);
in
{
  options.layers.layer-40.desktop.noctalia = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = hasDesktopTag;
      description = "Enable Noctalia Desktop Shell (v5)";
    };

    backend = lib.mkOption {
      type = lib.types.enum [
        "hyprland"
        "niri"
        "both"
      ];
      default = "hyprland";
      description = "Which compositor backend to use with Noctalia";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
      description = "The noctalia v5 package to use";
    };
  };

  home =
    { config, lib, ... }:
    {
      imports = lib.optionals cfg.enable [
        ./ipc.nix
        ./mutable-includes.nix
        inputs.noctalia.homeModules.default
      ];

      config = lib.mkIf cfg.enable {
        home.packages = with pkgs; [
          gst_all_1.gst-plugins-base
          gst_all_1.gst-plugins-good
        ];

        programs.noctalia = {
          enable = true;
          systemd.enable = true;
          package = cfg.package;
          validateConfig = true;

          settings = {
            # ── Shell ────────────────────────────────────────────────
            shell = {
              ui_scale = 1.0;
              corner_radius_scale = 1.0;
              font_family = "JetBrainsMono NF Medium";
              lang = "";
              time_format = "";
              date_format = "";
              polkit_agent = true;
              password_style = "random";
              launch_apps_as_systemd_services = true;
              telemetry_enabled = false;
              screen_time_enabled = true;
            };

            # ── Theme ────────────────────────────────────────────────
            theme = {
              mode = "dark";
              source = "wallpaper";
              wallpaper_scheme = "m3-content";
            };

            # ── Wallpaper ────────────────────────────────────────────
            wallpaper = {
              enabled = true;
              fill_mode = "crop";
              fill_color = "surface";
              directory = "$HOME/.background/4k Background";
              transition = [ "random" "honeycomb" ];
              transition_duration = 10000;
            };
            wallpaper.automation = {
              enabled = true;
              interval_seconds = 900;
              order = "random";
            };
            wallpaper.monitor = {
              "eDP-1" = { directory = "$HOME/.background/4k Background"; };
              "DP-1" = { directory = "$HOME/.background/4k Background"; };
              "HDMI-A-1" = { directory = "$HOME/.background/4k Background"; };
            };
            backdrop = {
              enabled = true;
              blur_intensity = 0.4;
              tint_intensity = 0.6;
            };

            # ── Bar ──────────────────────────────────────────────────
            bar = {
              position = "top";
              density = "comfortable";
              show_outline = true;
              show_capsule = true;
              background_opacity = 0.89;
              display_mode = "always_visible";
              frame_thickness = 7;
              frame_radius = 16;
              outer_corners = true;
              mouse_wheel_action = "workspace";
              right_click_action = "control_center";
            };
            bar.left = [
              {
                id = "Launcher";
                icon = "rocket";
                enable_colorization = true;
                colorize_system_icon = "secondary";
                use_distro_logo = true;
              }
              {
                id = "SystemMonitor";
                compact_mode = false;
                show_cpu_usage = true;
                show_cpu_cores = true;
                show_cpu_freq = true;
                show_cpu_temp = true;
                show_memory_usage = true;
                show_memory_as_percent = true;
                show_disk_usage = true;
                show_disk_usage_as_percent = true;
                show_network_stats = true;
                show_swap_usage = true;
                use_monospace_font = true;
              }
              { id = "plugin:ip-monitor"; }
              { id = "plugin:tailscale"; }
            ];
            bar.center = [
              {
                id = "MediaMini";
                compact_mode = false;
                show_album_art = true;
                show_progress_ring = true;
                show_visualizer = true;
                visualizer_type = "wave";
                scrolling_mode = "always";
                hide_when_idle = true;
                hide_mode = "transparent";
              }
              { id = "plugin:workspace-overview"; }
            ];
            bar.right = [
              { id = "plugin:screen-toolkit"; }
              { id = "plugin:todo"; }
              { id = "plugin:model-usage"; }
              {
                id = "Battery";
                display_mode = "graphic";
                show_power_profiles = true;
                hide_if_idle = true;
                hide_if_not_detected = true;
              }
              {
                id = "Volume";
                display_mode = "onhover";
                middle_click_command = "pwvucontrol || pavucontrol";
              }
              {
                id = "Clock";
                format_horizontal = "HH:mm ddd, MMM dd";
                format_vertical = "HH mm - dd MM";
                tooltip_format = "HH:mm ddd, MMM dd";
              }
              {
                id = "ControlCenter";
                icon = "bomb";
                enable_colorization = true;
                colorize_system_icon = "secondary";
              }
            ];

            # ── Dock ─────────────────────────────────────────────────
            dock = {
              enabled = true;
              position = "bottom";
              auto_hide = true;
              active_monitor_only = true;
              show_running = true;
              magnification = true;
              magnification_scale = 1.35;
            };

            # ── Launcher (shell.launcher) ─────────────────────────────
            shell.launcher = {
              categories = true;
              show_icons = true;
              sort_by_usage = true;
              session_search = true;
            };

            # ── Control Center ────────────────────────────────────────
            control_center = {
              shortcuts = {
                left = [
                  { id = "Network"; }
                  { id = "Bluetooth"; }
                  { id = "WallpaperSelector"; }
                  { id = "NoctaliaPerformance"; }
                ];
                right = [
                  { id = "Notifications"; }
                  { id = "PowerProfile"; }
                  { id = "KeepAwake"; }
                  { id = "NightLight"; }
                ];
              };
            };

            # ── Notifications ─────────────────────────────────────────
            notification = {
              enable_daemon = true;
              position = "top_right";
              layer = "overlay";
              background_opacity = 1;
            };

            # ── Session ───────────────────────────────────────────────
            session_menu = {
              enable_countdown = true;
              countdown_duration = 10000;
              position = "center";
              show_header = true;
              show_keybinds = true;
              large_buttons_style = true;
              large_buttons_layout = "single-row";
            };

            # ── Location ──────────────────────────────────────────────
            location = {
              address = "Los Angeles, CA";
            };

            # ── Night Light ───────────────────────────────────────────
            night_light = {
              enabled = true;
              auto_schedule = true;
              night_temp = "4000";
              day_temp = "6500";
              manual_sunrise = "06:30";
              manual_sunset = "18:30";
            };

            # ── Audio ─────────────────────────────────────────────────
            audio = {
            };

            # ── Brightness ────────────────────────────────────────────
            brightness = {
            };

            # ── OSD ───────────────────────────────────────────────────
            osd = {
              position = "bottom_center";
              orientation = "horizontal";
              scale = 1.0;
              background_opacity = 0.97;
            };

            # ── Idle ──────────────────────────────────────────────────
            idle = {
            };

            # ── Hooks ─────────────────────────────────────────────────
            hooks = {
            };
          };
        };

        home.file = {
          ".face".source = ../../../layers/00-cyberia/02-assets/user_profile/cloud.gif;
          ".face.icon".source = ../../../layers/00-cyberia/02-assets/user_profile/cloud.gif;
        };
      };
    };
}
