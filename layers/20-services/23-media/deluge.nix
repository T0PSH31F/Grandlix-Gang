{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.services.deluge-server;
in
{
  options.services.deluge-server = {
    enable = mkEnableOption "Deluge BitTorrent client";
    port = mkOption {
      type = types.port;
      default = 8113;
    };
  };

  config = mkIf cfg.enable {
    services.deluge = {
      enable = true;
      web = {
        enable = true;
        port = cfg.port;
      };
    };
    networking.firewall.allowedTCPPorts = [
      cfg.port
      58846
    ];

    systemd.tmpfiles.rules = [
      "d /var/lib/deluge 0750 deluge deluge -"
      "d /var/lib/deluge/.config 0750 deluge deluge -"
      "d /var/lib/deluge/.config/deluge 0750 deluge deluge -"
      "Z /var/lib/deluge 0750 deluge deluge -"
    ];

    systemd.services.delugeweb.serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "deluge";
      Group = "deluge";
      # Run permission fix as root before switching to user
      ExecStartPre = [
        "+${pkgs.writeShellScript "delugeweb-perms" ''
          mkdir -p /var/lib/deluge/.config/deluge
          # Ensure auth file exists and is populated to avoid TypeError in deluge-web
          if [ ! -s /var/lib/deluge/.config/deluge/auth ]; then
             echo "localclient:a7b8c9d0e1f2:10" > /var/lib/deluge/.config/deluge/auth
          fi
          chown -R deluge:deluge /var/lib/deluge
          chmod -R u+rwX,g+rX,o= /var/lib/deluge
        ''}"
      ];
    };
    systemd.services.deluged.serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "deluge";
      Group = "deluge";
    };

    # Persistence
    environment.persistence."/persist" = mkIf config.layers.layer-10.system.config.impermanence.enable {
      directories = [ "/var/lib/deluge" ];
    };
  };
}
