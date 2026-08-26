{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.layers.layer-60.gui.wl_shimeji;
  primaryUser = config.layers.meta.primaryUser or "t0psh31f";
in
{
  options.layers.layer-60.gui.wl_shimeji = {
    enable = mkEnableOption "wl_shimeji Wayland desktop mascot";

    package = mkOption {
      type = types.package;
      default = pkgs.wl_shimeji;
      description = "wl_shimeji package to install";
    };

    autostart = mkOption {
      type = types.bool;
      default = true;
      description = "Enable systemd user socket/service autostart";
    };

    theme = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Default shimeji mascot theme directory or name";
    };
  };

  nixos = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    warnings =
      optional (config.programs.hyprland.enable or false)
        "wl_shimeji: Hyprland detected. If mascot animations stutter or get tiled, ensure `windowrulev2 = float, class:^(wl_shimeji)$` and `windowrulev2 = noanim, class:^(wl_shimeji)$` are set in your Hyprland configuration.";

    environment.persistence."/persist" =
      mkIf (config.layers.layer-10.system.config.impermanence.enable or false)
        {
          users.${primaryUser}.directories = [
            ".config/wl_shimeji"
            ".local/share/wl_shimeji"
          ];
        };
  };

  home = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    systemd.user.sockets.wl_shimeji = mkIf cfg.autostart {
      Unit = {
        Description = "wl_shimeji Socket Listener";
        Documentation = "https://github.com/CluelessCatBurger/wl_shimeji";
      };
      Socket = {
        ListenStream = "%t/wl_shimeji.sock";
        SocketMode = "0600";
      };
      Install = {
        WantedBy = [ "sockets.target" ];
      };
    };

    systemd.user.services.wl_shimeji = mkIf cfg.autostart {
      Unit = {
        Description = "wl_shimeji Wayland Desktop Mascot Daemon";
        Documentation = "https://github.com/CluelessCatBurger/wl_shimeji";
        Requires = [ "wl_shimeji.socket" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart =
          "${cfg.package}/bin/wl_shimeji" + (if cfg.theme != null then " --theme ${cfg.theme}" else "");
        Restart = "on-failure";
        RestartSec = "5s";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
