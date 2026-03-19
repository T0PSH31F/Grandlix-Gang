{
  config,
  lib,
  pkgs,
  osConfig,
  inputs,
  ...
}:
let
  cfg = config.desktop.hyprland;
in
{
  imports = [
    ./scripts.nix
    ./monitors.nix
    ./animations.nix
    ./keybinds.nix
    ./rules.nix
    ./uwsm.nix
  ];

  options.desktop.hyprland = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = builtins.elem "desktop" (osConfig.machine.tags or [ ]);
      description = "Enable Hyprland Desktop Environment";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      adw-gtk3
      cliphist
      gedit
      ghostty
      google-chrome
      grim
      hue-plus
      hueadm
      hyprpolkitagent
      hyprland-qt-support
      hyprland-autoname-workspaces
      hyprkeys
      hyprmon
      hyprlax
      hyprsysteminfo
      #inputs.hypr-dynamic-cursors.packages.${pkgs.stdenv.hostPlatform.system}.hypr-dynamic-cursors
      jq
      kitty
      libnotify
      matugen
      nemo-with-extensions
      nwg-look
      openrgb-with-all-plugins
      openhue-cli
      playerctl
      pyprland
      pywalfox-native
      qt6Packages.qt6ct
      qt6Packages.qt5compat
      qt5.qtwayland
      qt6.qtwayland
      rofi
      rose-pine-hyprcursor
      slurp
      socat
      steam-rom-manager
      swayimg
      swaynotificationcenter
      swappy
      swww
      udiskie
      warp-terminal
      wev
      wl-clipboard
      xdg-user-dirs
      xdg-utils
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage =
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      systemd.enable = false;
      plugins = [
        #inputs.hypr-dynamic-cursors.packages.${pkgs.stdenv.hostPlatform.system}.hypr-dynamic-cursors
        # inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprexpo
        # inputs.hyprspace.packages.${pkgs.stdenv.hostPlatform.system}.Hyprspace
      ];

      settings = {
        source = [
          "~/.config/hypr/noctalia/noctalia-colors.conf" # Matugen colors
        ];

        "$primary" = "0xfff28fad";
        "$secondary" = "0xff575268";
        "$surfaceContainer" = "1f202e";

        #  plugin = {
        #    "dynamic-cursors" = {
        #      enabled = true;
        #      mode = "rotate";
        #      threshold = 2;
        #      # rotate = {
        #      #   length = "$cursorSize";
        #      # };
        #      tilt = {
        #        limit = 3000;
        #      };
        #      stretch = {
        #        limit = 3000;
        #        function = "quadratic";
        #      };
        #      shake = {
        #        enabled = false;
        #        effects = false;
        #        ipc = true;
        #      };
        #     # shaperule = "default, rotate, rotate:offset: $cursorRot";
        #    };
        #  };

        decoration = {
          screen_shader = "${config.home.homeDirectory}/.config/hypr/vibrancy.frag";
        };

        exec-once = [
          "pypr & disown"
          "hypr-sfx & disown"
          "udiskie & disown"
          #  "${pkgs.swww}/bin/swww-daemon & disown"
          "${pkgs.pipewire}/bin/pw-play ~/Clan/NFP/assets/SFX/login-sound.mp3 & disown"
          "noctalia-shell & disown"
        ];

        # Exec on shutdown
        exec-shutdown = [
          "${pkgs.pipewire}/bin/pw-play ~/Clan/NFP/assets/SFX/shutdown-sound.mp3"
        ];

        # General Layout Settings (Scrolling Layout)
        general = {
          border_size = 4;
          # "col.active_border" = "$active_border";
          # "col.inactive_border" = "$inactive_border";
          "col.active_border" = "$primary"; # Simplified to avoid gradient errors
          "col.inactive_border" = "0xff$surfaceContainer";
          resize_on_border = true;
          layout = "dwindle";
        };

        # Hyprexpo Overview config
        # "plugin:hyprexpo" = {
        #   columns = 3;
        #   gap_size = 5;
        #   bg_col = "rgb(111111)";
        #   workspace_method = "center current";
        #   enable_gesture = true;
        #   gesture_distance = 300;
        #   gesture_positive = true;
        # };

        # Window rules (Unified v0.53+ syntax)
        #  windowrule = [
        #    # Make picture-in-picture floating & pin it
        #    "float 1, match:title ^(Picture-in-Picture)$"
        #    "pin 1, match:title ^(Picture-in-Picture)$"
        #
        #    # Auth agents / Polkit
        #    "float 1, match:class ^(hyprpolkitagent)$"
        #
        #    # Thunar / Nemo file operation dialogs
        #    "float 1, match:title ^(File Operation Progress)$"
        #
        #    # Save/Open File Dialogs (XDG Portal, GTK, Qt)
        #    "float 1, match:class ^(xdg-desktop-portal-gtk)$"
        #    "float 1, match:title ^(Open File)$"
        #    "float 1, match:title ^(Save File)$"
        #    "float 1, match:title ^(Save As.*)$"
        #    "float 1, match:title ^(Choose Files)$"
        #  ];

        input = {
          kb_options = "caps:escape";
        };
      };
    };
    xdg.configFile."hypr/vibrancy.frag".source = ../../../../../../assets/vibrancy.frag;

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
    # Ensure the dynamic colors file exists so Hyprland doesn't crash on first boot
    #home.activation.createHyprlandDynamicColors = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    #  mkdir -p $HOME/.config/noctalia/templates
    #  if [ ! -f $HOME/.config/noctalia/templates/hyprland-colors.conf ]; then
    #    touch $HOME/.config/noctalia/templates/hyprland-colors.conf
    #  fi
    #'';
  };
}
