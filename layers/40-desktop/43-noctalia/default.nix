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

  home = { config, ... }: {
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
      settings = builtins.fromJSON (
        builtins.replaceStrings 
          [ "$HOME" ] 
          [ config.home.homeDirectory ] 
          (builtins.readFile ../../../layers/00-cyberia/02-assets/noctalia-config.json)
      );
    };

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
