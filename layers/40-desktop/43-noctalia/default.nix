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
      type = lib.types.enum [
        "hyprland"
        "niri"
        "both"
      ];
      default = "hyprland";
      description = "Which compositor backend to use with Noctalia (both = dual sessions via ReGreet)";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
      description = "The noctalia package to use";
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
        programs.noctalia-shell = {
          enable = true;
          package = cfg.package;
        };

        home.activation.setupNoctaliaConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          mkdir -p $HOME/.config/noctalia
          install -m644 ${
            pkgs.writeText "noctalia-settings.json" (
              builtins.replaceStrings [ "$HOME" ] [ config.home.homeDirectory ] (
                builtins.readFile ../../../layers/00-cyberia/02-assets/noctalia-config.json
              )
            )
          } $HOME/.config/noctalia/settings.json
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

        # Workaround for quickshell's unbounded qslog growth in /run/user/1000/quickshell
        systemd.user.services.quickshell-log-cleanup = {
          Unit = {
            Description = "Clean up quickshell detailed logs";
          };
          Service = {
            Type = "oneshot";
            ExecStart = "${pkgs.bash}/bin/bash -c 'find \${XDG_RUNTIME_DIR:-/run/user/1000}/quickshell/by-id -name \"log.qslog\" -mmin +60 -delete 2>/dev/null; find \${XDG_RUNTIME_DIR:-/run/user/1000}/quickshell/by-id -name \"log.qslog\" -size +50M -exec truncate -s 50M {} + 2>/dev/null; true'";
          };
        };

        systemd.user.timers.quickshell-log-cleanup = {
          Unit = {
            Description = "Periodic quickshell log cleanup";
          };
          Timer = {
            OnBootSec = "10min";
            OnUnitActiveSec = "1h";
          };
          Install = {
            WantedBy = [ "timers.target" ];
          };
        };

        home.file = {
          ".face".source = ../../../layers/00-cyberia/02-assets/user_profile/cloud.gif;
          ".face.icon".source = ../../../layers/00-cyberia/02-assets/user_profile/cloud.gif;
        };
      };
    };
}
