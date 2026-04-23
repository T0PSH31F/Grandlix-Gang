{
  config,
  lib,
  pkgs,
  inputs,
  osConfig,
  ...
}:
let
  cfg = config.desktop.noctalia;
  # Try to detect if we should auto-enable based on system tags (if available via osConfig)
  hasDesktopTag =
    if (builtins.hasAttr "machine" osConfig) then
      builtins.elem "desktop" (osConfig.machine.tags or [ ])
    else
      false;
in
{
  imports = [
    ./ipc.nix
    ./mutable-includes.nix
    inputs.noctalia.homeModules.default
    # ./niri.nix # Disabled: missing niri flake input
  ];

  options.desktop.noctalia = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = hasDesktopTag;
      description = "Enable Noctalia Desktop Shell";
    };

    backend = lib.mkOption {
      type = lib.types.enum [
        "hyprland"
        "niri"
      ];
      default = "hyprland";
      description = "Which compositor backend to use with Noctalia";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
      description = "The noctalia package to use";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.noctalia-shell = {
      enable = true;
      package = cfg.package;
      settings = builtins.fromJSON (
        builtins.replaceStrings 
          [ "$HOME" ] 
          [ config.home.homeDirectory ] 
          (builtins.readFile ../../../modules/00-cyberia/02-assets/noctalia-config.json)
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
      ".face".source = ../../../modules/00-cyberia/02-assets/user_profile/cloud.gif;
      ".face.icon".source = ../../../modules/00-cyberia/02-assets/user_profile/cloud.gif;
      ".config/homepage/.keep".text = "";
      ".config/BraveSoftware/Brave-Browser/Default/User StyleSheets/.keep".text = "";
      ".local/share/gedit/styles/.keep".text = "";
    };
  };
}
