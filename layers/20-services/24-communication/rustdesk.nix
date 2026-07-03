{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.layers.layer-20.services.communication.rustdesk;
in
{
  options.layers.layer-20.services.communication.rustdesk = {
    enable = mkEnableOption "RustDesk remote desktop client and server";

    client.enable = mkOption {
      type = types.bool;
      default = true;
      description = "Install the RustDesk GUI client";
    };

    server = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable the RustDesk server (signal + relay)";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = true;
        description = "Open firewall ports for RustDesk server (TCP 21115-21119, UDP 21116)";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # Client
    (mkIf cfg.client.enable {
      environment.systemPackages = [ pkgs.rustdesk ];
    })

    # Server
    (mkIf cfg.server.enable {
      services.rustdesk-server = {
        enable = true;
        openFirewall = cfg.server.openFirewall;
        signal.enable = true;
        relay.enable = true;
      };
    })
  ]);
}
