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
      description = "Enable Noctalia Desktop Shell";
    };

    backend = lib.mkOption {
      type = lib.types.enum [ "hyprland" "niri" ];
      default = "hyprland";
      description = "Which compositor backend to use with Noctalia";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
      description = "The noctalia package to use";
    };
  };

  home = { config, lib, ... }: {
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
      programs.noctalia-shell = {
        enable = true;
        package = cfg.package;
      };

      xdg.configFile."noctalia/colors.json".enable = lib.mkForce false;

      home.activation.setupNoctaliaConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
        mkdir -p $HOME/.config/noctalia
        install -m644 ${pkgs.writeText "noctalia-settings.json" (builtins.replaceStrings ["$HOME"] [config.home.homeDirectory] (builtins.readFile ../../../layers/00-cyberia/02-assets/noctalia-config.json))} $HOME/.config/noctalia/settings.json
        if [ -L $HOME/.config/noctalia/colors.json ]; then
          rm $HOME/.config/noctalia/colors.json
        fi
        if [ ! -f $HOME/.config/noctalia/colors.json ]; then
          install -m644 ${pkgs.writeText "noctalia-default-colors.json" ''
            {
              "mError": "#c0caf5",
              "mHover": "#b4f9f8",
              "mOnError": "#1a1b26",
              "mOnHover": "#1a1b26",
              "mOnPrimary": "#1a1b26",
              "mOnSecondary": "#1a1b26",
              "mOnSurface": "#a9b1d6",
              "mOnSurfaceVariant": "#787c99",
              "mOnTertiary": "#1a1b26",
              "mOutline": "#444b6a",
              "mPrimary": "#2ac3de",
              "mSecondary": "#bb9af7",
              "mShadow": "#1a1b26",
              "mSurface": "#1a1b26",
              "mSurfaceVariant": "#16161e",
              "mTertiary": "#b4f9f8"
            }
          ''} $HOME/.config/noctalia/colors.json
        fi
      '';

    systemd.user.services.noctalia-shell = {
      Unit = {
        Description = "Noctalia Desktop Shell";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${cfg.package}/bin/noctalia-shell";
        Restart = "always";
        RestartSec = "3";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    home.file = {
      ".face".source = ../../../layers/00-cyberia/02-assets/user_profile/cloud.gif;
      ".face.icon".source = ../../../layers/00-cyberia/02-assets/user_profile/cloud.gif;
    };
    };
  };
}
