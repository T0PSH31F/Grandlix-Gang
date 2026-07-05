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

            theme = {
              mode = "dark";
              source = "wallpaper";
              wallpaper_scheme = "m3-content";
            };

            wallpaper = {
              enabled = true;
              fill_mode = "crop";
              fill_color = "surface";
              directory = "$HOME/.background/4k Background";
              automation_enabled = true;
              wallpaper_change_mode = "random";
              random_interval_sec = 900;
              transition_duration = 10000;
              transition_type = [
                "random"
                "honeycomb"
              ];
              use_wallhaven = true;
              wallhaven_query = "Neon Anime 8k";
              wallhaven_sorting = "relevance";
              wallhaven_order = "desc";
              wallhaven_categories = "111";
              wallhaven_purity = "100";
              overview_enabled = true;
              overview_blur = 0.4;
              overview_tint = 0.6;
              monitor_directories = [
                {
                  name = "eDP-1";
                  directory = "$HOME/.background/4k Background";
                  wallpaper = "";
                }
                {
                  name = "DP-1";
                  directory = "$HOME/.background/4k Background";
                  wallpaper = "";
                }
                {
                  name = "HDMI-A-1";
                  directory = "$HOME/.background/4k Background";
                  wallpaper = "";
                }
              ];
            };

            bar = {
              bar_type = "framed";
              position = "top";
              density = "comfortable";
              show_outline = true;
              show_capsule = true;
              background_opacity = 0.89;
              display_mode = "always_visible";
              frame_thickness = 7;
              frame_radius = 16;
              outer_corners = true;
              widgets = {
                left = [
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
                  {
                    id = "plugin:ip-monitor";
                  }
                  {
                    id = "plugin:tailscale";
                  }
                ];
                center = [
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
                  {
                    id = "plugin:workspace-overview";
                  }
                ];
                right = [
                  {
                    id = "plugin:screen-toolkit";
                  }
                  {
                    id = "plugin:todo";
                  }
                  {
                    id = "plugin:model-usage";
                  }
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
              };
              mouse_wheel_action = "workspace";
              right_click_action = "controlCenter";
            };

            dock = {
              enabled = true;
              position = "bottom";
              display_mode = "auto_hide";
              dock_type = "floating";
              only_same_output = true;
              show_launcher_icon = true;
              indicator_color = "primary";
              indicator_thickness = 6;
              indicator_opacity = 0.92;
              animation_speed = 1.52;
            };

            app_launcher = {
              enable_clipboard_history = true;
              position = "top_center";
              sort_by_most_used = true;
              terminal_command = "ghostty -e";
              view_mode = "grid";
              show_categories = true;
              icon_mode = "native";
              enable_settings_search = true;
              enable_windows_search = true;
              enable_session_search = true;
            };

            control_center = {
              position = "top_center";
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
              cards = [
                { enabled = true; id = "profile-card"; }
                { enabled = true; id = "shortcuts-card"; }
                { enabled = true; id = "audio-card"; }
                { enabled = false; id = "brightness-card"; }
                { enabled = true; id = "weather-card"; }
                { enabled = true; id = "media-sysmon-card"; }
              ];
            };

            notifications = {
              enabled = true;
              enable_markdown = true;
              location = "top_right";
              overlay_layer = true;
              background_opacity = 1;
              sounds = {
                enabled = true;
                volume = 0.75;
                separate_sounds = true;
                critical_sound_file = "$HOME/Clan/NFP/layers/00-cyberia/02-assets/SFX/notifynorm.wav";
                normal_sound_file = "$HOME/Clan/NFP/layers/00-cyberia/02-assets/SFX/notifynorm.wav";
                low_sound_file = "$HOME/Clan/NFP/layers/00-cyberia/02-assets/SFX/notifynorm.wav";
                excluded_apps = "discord";
              };
              enable_media_toast = false;
              enable_keyboard_layout_toast = true;
              enable_battery_toast = true;
            };

            session_menu = {
              enable_countdown = true;
              countdown_duration = 10000;
              position = "center";
              show_header = true;
              show_keybinds = true;
              large_buttons_style = true;
              large_buttons_layout = "single-row";
              power_options = [
                { action = "lock"; enabled = true; keybind = "1"; }
                { action = "suspend"; enabled = true; keybind = "2"; }
                { action = "hibernate"; enabled = true; keybind = "3"; }
                { action = "reboot"; enabled = true; keybind = "4"; }
                { action = "logout"; enabled = true; keybind = "5"; }
                { action = "shutdown"; enabled = true; keybind = "6"; }
                { action = "rebootToUefi"; enabled = true; keybind = "7"; }
              ];
            };

            location = {
              name = "Los_Angeles";
              weather_enabled = true;
              weather_show_effects = true;
              use_fahrenheit = true;
              use_12hour_format = true;
              show_week_number_in_calendar = true;
              show_calendar_events = true;
              show_calendar_weather = true;
              analog_clock_in_calendar = true;
              first_day_of_week = -1;
            };

            night_light = {
              enabled = true;
              auto_schedule = true;
              night_temp = "4000";
              day_temp = "6500";
              manual_sunrise = "06:30";
              manual_sunset = "18:30";
            };

            audio = {
              volume_step = 5;
              volume_overdrive = false;
              preferred_player = "Spotify";
              volume_feedback = true;
              volume_feedback_sound_file = "$HOME/Clan/NFP/layers/00-cyberia/02-assets/SFX/volume-feedback.wav";
            };

            brightness = {
              brightness_step = 5;
              enforce_minimum = true;
            };

            osd = {
              enabled = true;
              location = "bottom";
              auto_hide_ms = 2000;
              overlay_layer = true;
            };

            network = {
              bluetooth_auto_connect = true;
              network_panel_view = "wifi";
            };

            system_monitor = {
              cpu_warning_threshold = 80;
              cpu_critical_threshold = 90;
              temp_warning_threshold = 80;
              temp_critical_threshold = 90;
              mem_warning_threshold = 80;
              mem_critical_threshold = 90;
            };

            idle = {
              enabled = false;
              screen_off_timeout = 600;
              lock_timeout = 660;
              suspend_timeout = 1800;
              fade_duration = 5;
            };

            desktop_widgets = {
              enabled = true;
              overview_enabled = true;
            };

            templates = {
              enable_builtin_templates = true;
              enable_community_templates = true;
              builtin_ids = [
                "btop"
                "cava"
                "hyprland"
                "hyprtoolkit"
                "ghostty"
                "discord"
                "scroll"
                "zed"
                "qt"
                "kitty"
                "helix"
                "foot"
                "pywalfox"
                "steam"
                "code"
                "zathura"
                "yazi"
                "vicinae"
                "spicetify"
                "kcolorscheme"
                "gtk"
                "telegram"
                "fuzzel"
                "wezterm"
                "starship"
              ];
            };

            hooks = {
              enabled = false;
            };

            plugins = {
              auto_update = true;
              notify_updates = true;
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
