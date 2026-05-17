{
  config,
  lib,
  pkgs,
  osConfig ? config,
  inputs,
  ...
}:
let
  cfg = osConfig.layers.layer-40.desktop.hyprland;
in
{
  options.layers.layer-40.desktop.hyprland = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = builtins.elem "desktop" (osConfig.machine.tags or [ ]);
      description = "Enable Hyprland Desktop Environment";
    };

    isNvidia = lib.mkOption {
      type = lib.types.bool;
      default = osConfig.hardware.nvidia.enable or false;
      description = "Internal: True if the machine has NVIDIA hardware enabled";
    };

    isLaptop = lib.mkOption {
      type = lib.types.bool;
      default = builtins.elem "laptop" (osConfig.machine.tags or [ ]);
      description = "Internal: True if the machine is a laptop";
    };

    sfx = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable UI sound effects daemon";
      };

      sounds = {
        switchFocus = lib.mkOption {
          type = lib.types.str;
          default = "switch-focus.wav";
          description = "Sound to play when focusing a window";
        };
        moveWindow = lib.mkOption {
          type = lib.types.str;
          default = "move-window.wav";
          description = "Sound to play when moving a window";
        };
        openWindow = lib.mkOption {
          type = lib.types.str;
          default = "open-window.wav";
          description = "Sound to play when opening a window";
        };
        closeWindow = lib.mkOption {
          type = lib.types.str;
          default = "close-window.wav";
          description = "Sound to play when closing a window";
        };
      };
    };
  };

  nixos = lib.mkIf cfg.enable {
    programs.hyprland.enable = true;

    programs.uwsm = {
      enable = true;
      waylandCompositors = {
        hyprland = {
          prettyName = "Hyprland";
          comment = "Hyprland compositor managed by UWSM";
          binPath = "/run/current-system/sw/bin/Hyprland";
        };
      };
    };
  };

  # Home Manager level config
  home = { config, ... }:
  let
    sonic-hyprcursor = pkgs.stdenv.mkDerivation {
      pname = "sonic-hyprcursor";
      version = "1.0.0";
      src = ../../00-cyberia/02-assets/cursors/Sonic-cursor-hyprcursor;
      installPhase = ''
        mkdir -p $out/share/icons/Sonic-Hyprcursor
        cp -r Sonic-Hyprcursor/* $out/share/icons/Sonic-Hyprcursor/
      '';
    };
  in
  {
    imports = lib.optionals cfg.enable [
      ./scripts.nix
      ./monitors.nix
      ./animations.nix
      ./keybinds.nix
      ./rules.nix
      ./uwsm.nix
    ];

    config = lib.mkIf cfg.enable {
      home.packages = with pkgs; [
      adw-gtk3
      awww
      cliphist
      gedit
      ghostty
      google-chrome
      grim
      hue-plus
      hueadm
      hyprcursor
      wl-freeze
      hyprkeys
      hyprland-autoname-workspaces
      hyprland-qt-support
      hyprlax
      hyprlang
      hyprls
      hyprmon
      hyprpolkitagent
      hyprpwcenter
      hyprsysteminfo
      hyprviz
      jq
      kitty
      libnotify
      matugen
      nemo-with-extensions
      nwg-look
      openhue-cli
      openrgb-with-all-plugins
      playerctl
      pyprland
      pywalfox-native
      qt5.qtwayland
      qt6.qtwayland
      qt6Packages.qt5compat
      qt6Packages.qt6ct
      rofi
      sonic-hyprcursor
      slurp
      socat
      steam-rom-manager
      swappy
      swayimg
      swaynotificationcenter
      udiskie
      warp-terminal
      wev
      wl-clipboard
      xdg-user-dirs
      xdg-utils
    ];

    home.pointerCursor = {
      package = sonic-hyprcursor;
      name = "Sonic-Hyprcursor";
      size = 32;
      gtk.enable = true;
      x11.enable = true;
      hyprcursor = {
        enable = true;
        size = 32;
      };
    };
    
    gtk = {
      enable = true;
      gtk4.theme = null;
    };

    wayland.windowManager.hyprland = {
      enable = true;
      configType = "hyprlang";
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage =
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      systemd.enable = true;
      plugins = [
        inputs.hypr-dynamic-cursors.packages.${pkgs.stdenv.hostPlatform.system}.hypr-dynamic-cursors
      ];

      settings = {
        source = [
          "~/.config/hypr/noctalia/noctalia-colors.conf"
          "~/.config/hypr/monitors.conf"
        ];

        "$primary" = "0xfff28fad";
        "$secondary" = "0xff575268";
        "$surfaceContainer" = "1f202e";

        plugin = {
          "dynamic-cursors" = {
            enabled = true;
            mode = "rotate";
            threshold = 2;
            tilt = { limit = 3000; };
            stretch = { limit = 3000; function = "quadratic"; };
            shake = { enabled = false; effects = false; ipc = true; };
          };
        };

        decoration = {
          screen_shader = "${config.home.homeDirectory}/.config/hypr/vibrancy.frag";
        };

        exec-once = [
          "pypr & disown"
          "hypr-sfx & disown"
          "udiskie & disown"
          "${pkgs.pipewire}/bin/pw-play ~/Clan/NFP/layers/00-cyberia/02-assets/SFX/login-sound.mp3 & disown"
        ];

        exec-shutdown = [
          "${pkgs.pipewire}/bin/pw-play ~/Clan/NFP/layers/00-cyberia/02-assets/SFX/shutdown-sound.mp3"
        ];

        general = {
          border_size = 4;
          "col.active_border" = lib.mkForce "$primary";
          "col.inactive_border" = lib.mkForce "0xff$surfaceContainer";
          resize_on_border = true;
          layout = "dwindle";
        };

        input = { kb_options = "caps:escape"; };
        cursor = {
          no_hardware_cursors = cfg.isNvidia;  # Only disable for NVIDIA
        };

        # NVIDIA stability fixes (no-op on Intel/AMD)
        render = lib.mkIf cfg.isNvidia {
          direct_scanout = false;   # Prevent buffer format mismatches on NVIDIA multi-monitor
        };
      };
    };

    xdg.configFile."hypr/vibrancy.frag".source = ../../../layers/00-cyberia/02-assets/vibrancy.frag;
    xdg.configFile."hypr/hyprland.conf".force = true;
    xdg.configFile."hypr/pyprland.toml".text = ''
      [pyprland]
      plugins = ["scratchpads"]

      [scratchpads.term]
      animation = "fromTop"
      command = "ghostty --class=ghostty-dropdown"
      class = "ghostty-dropdown"
      size = "100% 50%"
      lazy = true

      [scratchpads.gedit]
      animation = "fromRight"
      command = "gedit"
      class = "gedit"
      size = "75% 60%"
      position = "center"
      lazy = true

      [scratchpads.nwglook]
      animation = "fromBottom"
      command = "nwg-look"
      class = "nwg-look"
      size = "60% 60%"
      position = "center"
      lazy = true
    '';
    xdg.enable = true;
    };
  };
}
